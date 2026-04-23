import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/consts/app_consts.dart';
import '../../routes/app_routes.dart';
import '../../models/app_models.dart';
import '../auth/auth_controller.dart';

class GroupController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController _authCtrl = Get.find<AuthController>();

  final RxList<GroupModel> myGroups = <GroupModel>[].obs;
  final Rx<GroupModel?> currentGroup = Rx<GroupModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authCtrl.currentUser, (_) => _loadMyGroups());
    ever(_authCtrl.currentGroupId, (_) => _loadCurrentGroup());
  }

  Future<void> _loadMyGroups() async {
    final user = _authCtrl.currentUser.value;
    if (user == null) return;
    final groupIds = user.groupRoles.keys.toList();
    if (groupIds.isEmpty) {
      myGroups.clear();
      return;
    }

    final snap = await _db
        .collection(AppConsts.colGroups)
        .where(FieldPath.documentId, whereIn: groupIds)
        .get();

    myGroups.value =
        snap.docs.map((d) => GroupModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> _loadCurrentGroup() async {
    final id = _authCtrl.currentGroupId.value;
    if (id.isEmpty) return;
    final doc =
        await _db.collection(AppConsts.colGroups).doc(id).get();
    if (doc.exists) {
      currentGroup.value = GroupModel.fromMap(doc.data()!, doc.id);
    }
  }

  Stream<GroupModel?> streamCurrentGroup() {
    final id = _authCtrl.currentGroupId.value;
    if (id.isEmpty) return const Stream.empty();
    return _db
        .collection(AppConsts.colGroups)
        .doc(id)
        .snapshots()
        .map((s) => s.exists ? GroupModel.fromMap(s.data()!, s.id) : null);
  }

  // ── Create Group ────────────────────────────────────────────────────────

  Future<void> createGroup({
    required String name,
    required int totalPointsPerTeam,
    required int minPlayerPoints,
    required int maxPlayersPerTeam,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = _authCtrl.currentUser.value!;
      final groupId = const Uuid().v4();

      final group = GroupModel(
        id: groupId,
        name: name.trim(),
        adminUid: user.uid,
        adminPhone: user.phone,
        totalPointsPerTeam: totalPointsPerTeam,
        minPlayerPoints: minPlayerPoints,
        maxPlayersPerTeam: maxPlayersPerTeam,
        createdAt: DateTime.now(),
      );

      await _db
          .collection(AppConsts.colGroups)
          .doc(groupId)
          .set(group.toMap());

      // Update user roles
      await _db.collection(AppConsts.colUsers).doc(user.uid).update({
        'groupRoles.$groupId': AppConsts.roleAdmin,
      });

      _authCtrl.currentUser.value = user.copyWith(
        groupRoles: {...user.groupRoles, groupId: AppConsts.roleAdmin},
      );

      myGroups.add(group);
      await _authCtrl.setCurrentGroup(groupId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Update Group Settings ────────────────────────────────────────────────

  Future<void> updateGroupSettings({
    required String groupId,
    String? name,
    int? totalPointsPerTeam,
    int? minPlayerPoints,
    int? maxPlayersPerTeam,
    String? teamThemeColor,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (totalPointsPerTeam != null)
      updates['totalPointsPerTeam'] = totalPointsPerTeam;
    if (minPlayerPoints != null) updates['minPlayerPoints'] = minPlayerPoints;
    if (maxPlayersPerTeam != null)
      updates['maxPlayersPerTeam'] = maxPlayersPerTeam;
    if (teamThemeColor != null) updates['teamThemeColor'] = teamThemeColor;

    await _db.collection(AppConsts.colGroups).doc(groupId).update(updates);
    await _loadCurrentGroup();
  }

  // ── Team Theme Color ─────────────────────────────────────────────────────

  Future<void> setTeamThemeColor(String groupId, String hexColor) async {
    await _db
        .collection(AppConsts.colGroups)
        .doc(groupId)
        .update({'teamThemeColor': hexColor});
    await _loadCurrentGroup();
  }

  // ── Timetable URL ────────────────────────────────────────────────────────

  Future<void> updateTimetableUrl(String groupId, String url) async {
    await _db
        .collection(AppConsts.colGroups)
        .doc(groupId)
        .update({'timetableUrl': url});
    await _loadCurrentGroup();
  }

  GroupModel? get group => currentGroup.value;
  String get groupId => _authCtrl.currentGroupId.value;
  int get totalPoints => group?.totalPointsPerTeam ?? 100;
  int get minPlayerPoints => group?.minPlayerPoints ?? 1;
  int get maxPlayersPerTeam => group?.maxPlayersPerTeam ?? 15;
}
