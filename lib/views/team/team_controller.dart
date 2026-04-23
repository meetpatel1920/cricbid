import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricbid/models/team_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import '../../core/consts/app_consts.dart';
import '../auth/auth_controller.dart';
import '../group/group_controller.dart';

class TeamController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController _authCtrl = Get.find<AuthController>();
  final GroupController _groupCtrl = Get.find<GroupController>();

  final RxList<TeamModel> teams = <TeamModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authCtrl.currentGroupId, (_) => loadTeams());
    loadTeams();
  }

  String get _groupId => _authCtrl.currentGroupId.value;

  Stream<List<TeamModel>> streamTeams(String groupId) {
    return _db
        .collection(AppConsts.colTeams)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map((d) => TeamModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> loadTeams() async {
    if (_groupId.isEmpty) return;
    isLoading.value = true;
    try {
      final snap = await _db.collection(AppConsts.colTeams).where('groupId', isEqualTo: _groupId).orderBy('createdAt').get();
      teams.value = snap.docs.map((d) => TeamModel.fromMap(d.data(), d.id)).toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<TeamModel?> getTeam(String teamId) async {
    final doc = await _db.collection(AppConsts.colTeams).doc(teamId).get();
    if (doc.exists) return TeamModel.fromMap(doc.data()!, doc.id);
    return null;
  }

  // ── Add Single Team ──────────────────────────────────────────────────────

  Future<void> addTeam({
    required String name,
    required String ownerName,
    required String ownerPhone,
    String? ownerAddress,
    DateTime? ownerBirthdate,
    required String ownerType,
    String? ownerLastTeam,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final teamId = const Uuid().v4();
      final group = _groupCtrl.group!;

      final team = TeamModel(
        id: teamId,
        groupId: _groupId,
        name: name.trim(),
        ownerName: ownerName.trim(),
        ownerPhone: ownerPhone.trim(),
        ownerAddress: ownerAddress,
        ownerBirthdate: ownerBirthdate,
        ownerType: ownerType,
        ownerLastTeam: ownerLastTeam,
        totalPoints: group.totalPointsPerTeam,
        createdAt: DateTime.now(),
      );

      await _db.collection(AppConsts.colTeams).doc(teamId).set(team.toMap());

      // Check if owner already has an account, link them
      final userQuery = await _db.collection(AppConsts.colUsers).where('phone', isEqualTo: '+91${ownerPhone.trim()}').get();
      if (userQuery.docs.isNotEmpty) {
        final ownerDoc = userQuery.docs.first;
        await _db.collection(AppConsts.colTeams).doc(teamId).update({'ownerUid': ownerDoc.id});
        await ownerDoc.reference.update({
          'groupRoles.$_groupId': AppConsts.roleOwner,
        });
      }

      teams.add(team);
      Get.back();
      Get.snackbar('Success', '${name} team added!');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Bulk Import from Excel ───────────────────────────────────────────────

  Future<void> importTeamsFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) return;

      final bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first]!;

      isLoading.value = true;
      int added = 0;

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty || row[AppConsts.excelTeamName]?.value == null) continue;

        final name = row[AppConsts.excelTeamName]?.value?.toString().trim() ?? '';
        final ownerName = row[AppConsts.excelTeamOwnerName]?.value?.toString().trim() ?? '';
        final ownerPhone = row[AppConsts.excelTeamOwnerPhone]?.value?.toString().trim() ?? '';
        final ownerType = row[AppConsts.excelTeamOwnerType]?.value?.toString().trim() ?? AppConsts.typeBatting;

        if (name.isEmpty || ownerPhone.isEmpty) continue;

        await addTeam(
          name: name,
          ownerName: ownerName,
          ownerPhone: ownerPhone,
          ownerAddress: row[AppConsts.excelTeamOwnerAddress]?.value?.toString(),
          ownerType: ownerType,
          ownerLastTeam: row[AppConsts.excelTeamLastTeam]?.value?.toString(),
        );
        added++;
      }

      Get.snackbar('Import Complete', '$added teams imported');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Update Team Logo/Theme ────────────────────────────────────────────────

  Future<void> updateTeamLogo(String teamId, String logoUrl) async {
    await _db.collection(AppConsts.colTeams).doc(teamId).update({'logoUrl': logoUrl});
    await loadTeams();
  }

  Future<void> updateTeamTheme(String teamId, String hexColor) async {
    await _db.collection(AppConsts.colTeams).doc(teamId).update({'themeColor': hexColor});
    // Sync to group-level theme
    await _db.collection(AppConsts.colGroups).doc(_groupId).update({'teamThemeColor': hexColor});
    await loadTeams();
  }

  // ── Budget Helpers ────────────────────────────────────────────────────────

  /// Validate if a bid is valid for a team
  /// Returns null if valid, error message if invalid
  String? validateBid({
    required TeamModel team,
    required int bidPoints,
    required int minPlayerPoints,
  }) {
    final remaining = team.remainingPoints;
    final playersStillNeeded = _groupCtrl.maxPlayersPerTeam - team.playerCount;

    if (bidPoints < minPlayerPoints) {
      return 'Minimum bid is $minPlayerPoints points';
    }
    if (bidPoints > remaining) {
      return 'Insufficient budget. Remaining: $remaining pts';
    }

    if (playersStillNeeded > 1) {
      final reserveNeeded = (playersStillNeeded - 1) * minPlayerPoints;
      if (remaining - bidPoints < reserveNeeded) {
        return 'Need to reserve $reserveNeeded pts for ${playersStillNeeded - 1} more players';
      }
    }

    return null;
  }

  // ── Deduct Points After Sold ──────────────────────────────────────────────

  Future<void> recordPlayerSold(String teamId, int points, String playerId) async {
    await _db.collection(AppConsts.colTeams).doc(teamId).update({
      'spentPoints': FieldValue.increment(points),
      'playerCount': FieldValue.increment(1),
    });
    await loadTeams();
  }

  // ── Get Owner's Team ──────────────────────────────────────────────────────

  TeamModel? getOwnerTeam(String ownerUid) {
    try {
      return teams.firstWhere((t) => t.ownerUid == ownerUid);
    } catch (_) {
      return null;
    }
  }
}
