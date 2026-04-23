import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/consts/app_consts.dart';
import '../../services/pdf_generator.dart';
import '../../models/app_models.dart';
import '../auth/auth_controller.dart';
import '../group/group_controller.dart';
import '../team/team_controller.dart';
import '../../services/notification_service.dart';

class TimetableController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authCtrl = Get.find<AuthController>();
  final GroupController _groupCtrl = Get.find<GroupController>();
  final TeamController _teamCtrl = Get.find<TeamController>();

  final RxList<TimetableModel> timetables = <TimetableModel>[].obs;
  final RxList<MatchModel> matches = <MatchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get _groupId => _authCtrl.currentGroupId.value;

  @override
  void onInit() {
    super.onInit();
    loadTimetables();
  }

  Future<void> loadTimetables() async {
    if (_groupId.isEmpty) return;
    isLoading.value = true;
    try {
      final snap = await _db
          .collection(AppConsts.colTimetables)
          .where('groupId', isEqualTo: _groupId)
          .orderBy('createdAt', descending: true)
          .get();
      timetables.value =
          snap.docs.map((d) => TimetableModel.fromMap(d.data(), d.id)).toList();
      if (timetables.isNotEmpty) {
        await loadMatches(timetables.first.id);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMatches(String timetableId) async {
    final snap = await _db
        .collection(AppConsts.colMatches)
        .where('timetableId', isEqualTo: timetableId)
        .orderBy('scheduledAt')
        .get();
    matches.value =
        snap.docs.map((d) => MatchModel.fromMap(d.data(), d.id)).toList();
  }

  // ── Auto-generate Timetable ───────────────────────────────────────────────

  Future<void> generateTimetable({
    required String name,
    required DateTime fromDate,
    required DateTime toDate,
    required int matchesPerDay,
    required bool useGroups,
    required int numGroups, // only if useGroups=true
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final teams = _teamCtrl.teams;
      if (teams.isEmpty) {
        errorMessage.value = 'No teams found';
        return;
      }

      // Shuffle teams
      final shuffled = List<TeamModel>.from(teams)..shuffle(Random());

      // Create group assignments
      Map<String, List<String>> groupTeams = {};
      List<MatchModel> generatedMatches = [];
      int matchNumber = 1;

      if (useGroups && numGroups > 1) {
        // Divide teams into groups
        final groupLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
        for (int g = 0; g < numGroups; g++) {
          final label = 'Group ${groupLabels[g]}';
          groupTeams[label] = [];
        }

        for (int i = 0; i < shuffled.length; i++) {
          final groupLabel = 'Group ${groupLabels[i % numGroups]}';
          groupTeams[groupLabel]!.add(shuffled[i].id);
        }

        // Generate group stage matches (round robin within each group)
        for (final entry in groupTeams.entries) {
          final groupTeamIds = entry.key;
          final teamIds = entry.value;
          final stageMatches = _generateRoundRobin(
            teamIds: teamIds,
            teamNames: {for (var t in teams) t.id: t.name},
            stage: 'group_${entry.key.split(' ').last.toLowerCase()}',
            startMatchNumber: matchNumber,
          );
          generatedMatches.addAll(stageMatches);
          matchNumber += stageMatches.length;
        }

        // Semi-finals (1st from each group)
        if (numGroups >= 4) {
          final sf1 = _createPlaceholderMatch(
              'SF1', 'semi_final_1', matchNumber++);
          final sf2 = _createPlaceholderMatch(
              'SF2', 'semi_final_2', matchNumber++);
          generatedMatches.addAll([sf1, sf2]);
        }

        // Final
        generatedMatches.add(
            _createPlaceholderMatch('Final', 'final', matchNumber++));
      } else {
        // Simple round robin, no groups
        final teamIds = shuffled.map((t) => t.id).toList();
        generatedMatches = _generateRoundRobin(
          teamIds: teamIds,
          teamNames: {for (var t in teams) t.id: t.name},
          stage: 'league',
          startMatchNumber: 1,
        );
        matchNumber = generatedMatches.length + 1;
        generatedMatches.add(
            _createPlaceholderMatch('Final', 'final', matchNumber));
      }

      // Assign dates/times
      _assignMatchDates(
        matches: generatedMatches,
        fromDate: fromDate,
        toDate: toDate,
        matchesPerDay: matchesPerDay,
      );

      // Save timetable
      final ttId = const Uuid().v4();
      final timetable = TimetableModel(
        id: ttId,
        groupId: _groupId,
        name: name,
        fromDate: fromDate,
        toDate: toDate,
        matchesPerDay: matchesPerDay,
        useGroups: useGroups,
        numGroups: numGroups,
        groupTeams: groupTeams,
        createdAt: DateTime.now(),
      );
      await _db
          .collection(AppConsts.colTimetables)
          .doc(ttId)
          .set(timetable.toMap());

      // Save matches
      final batch = _db.batch();
      for (final match in generatedMatches) {
        final matchId = const Uuid().v4();
        final matchWithGroup = MatchModel(
          id: matchId,
          groupId: _groupId,
          timetableId: ttId,
          team1Id: match.team1Id,
          team1Name: match.team1Name,
          team2Id: match.team2Id,
          team2Name: match.team2Name,
          stage: match.stage,
          matchNumber: match.matchNumber,
          scheduledAt: match.scheduledAt,
        );
        batch.set(_db.collection(AppConsts.colMatches).doc(matchId),
            matchWithGroup.toMap());
      }
      await batch.commit();

      // Generate PDF
      final pdfFile = await PdfGenerator.generateTimetablePdf(
        matches: generatedMatches,
        groupName: _groupCtrl.group?.name ?? '',
        timetableName: name,
      );

      // Upload PDF
      final pdfRef = _storage
          .ref()
          .child(AppConsts.storageTimetables)
          .child('$ttId.pdf');
      await pdfRef.putFile(pdfFile);
      final pdfUrl = await pdfRef.getDownloadURL();

      await _db
          .collection(AppConsts.colTimetables)
          .doc(ttId)
          .update({'pdfUrl': pdfUrl});

      await _groupCtrl.updateTimetableUrl(_groupId, pdfUrl);

      // Notify all
      await NotificationService.instance.sendGroupNotification(
        groupId: _groupId,
        title: '📅 Timetable Published!',
        body: 'Match schedule for ${_groupCtrl.group?.name} is ready. Check it now!',
        type: 'timetable',
      );

      // Schedule match notifications
      await _scheduleMatchNotifications(generatedMatches);

      timetables.insert(0, timetable);
      matches.value = generatedMatches;

      Get.back();
      // Offer share
      await PdfGenerator.sharePdf(pdfFile,
          subject: '${_groupCtrl.group?.name} Timetable');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Round Robin Generator ─────────────────────────────────────────────────

  List<MatchModel> _generateRoundRobin({
    required List<String> teamIds,
    required Map<String, String> teamNames,
    required String stage,
    required int startMatchNumber,
  }) {
    final matches = <MatchModel>[];
    int num = startMatchNumber;
    for (int i = 0; i < teamIds.length; i++) {
      for (int j = i + 1; j < teamIds.length; j++) {
        matches.add(MatchModel(
          id: '',
          groupId: _groupId,
          timetableId: '',
          team1Id: teamIds[i],
          team1Name: teamNames[teamIds[i]] ?? '',
          team2Id: teamIds[j],
          team2Name: teamNames[teamIds[j]] ?? '',
          stage: stage,
          matchNumber: num++,
          scheduledAt: DateTime.now(), // Will be set later
        ));
      }
    }
    return matches;
  }

  MatchModel _createPlaceholderMatch(
      String label, String stage, int number) {
    return MatchModel(
      id: '',
      groupId: _groupId,
      timetableId: '',
      team1Id: 'tbd',
      team1Name: 'TBD',
      team2Id: 'tbd2',
      team2Name: 'TBD',
      stage: stage,
      matchNumber: number,
      scheduledAt: DateTime.now(),
    );
  }

  // ── Assign Dates ──────────────────────────────────────────────────────────

  void _assignMatchDates({
    required List<MatchModel> matches,
    required DateTime fromDate,
    required DateTime toDate,
    required int matchesPerDay,
  }) {
    if (matches.isEmpty) return;

    DateTime currentDate = DateTime(
        fromDate.year, fromDate.month, fromDate.day, 10, 0);
    int matchesOnDay = 0;
    const Duration matchGap = Duration(hours: 3);

    for (int i = 0; i < matches.length; i++) {
      if (matchesOnDay >= matchesPerDay) {
        currentDate = DateTime(currentDate.year, currentDate.month,
            currentDate.day + 1, 10, 0);
        matchesOnDay = 0;
      }

      if (currentDate.isAfter(toDate)) {
        // Overflow: stack on last day
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      final updated = MatchModel(
        id: matches[i].id,
        groupId: matches[i].groupId,
        timetableId: matches[i].timetableId,
        team1Id: matches[i].team1Id,
        team1Name: matches[i].team1Name,
        team2Id: matches[i].team2Id,
        team2Name: matches[i].team2Name,
        stage: matches[i].stage,
        matchNumber: matches[i].matchNumber,
        scheduledAt:
            currentDate.add(Duration(hours: matchesOnDay * 3)),
      );
      matches[i] = updated;
      matchesOnDay++;
    }
  }

  // ── Schedule Match Notifications ─────────────────────────────────────────

  Future<void> _scheduleMatchNotifications(
      List<MatchModel> matches) async {
    for (final match in matches) {
      if (match.team1Id == 'tbd') continue;
      await NotificationService.instance.scheduleMatchNotification(
        id: match.matchNumber,
        title: '🏏 Match Today!',
        body:
            '${match.team1Name} vs ${match.team2Name} — Get ready, match in 2 hours!',
        scheduledTime: match.scheduledAt,
      );
    }
  }

  // ── Upload Custom Timetable Image/PDF ─────────────────────────────────────

  Future<void> uploadCustomTimetable() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) return;

      isLoading.value = true;
      final bytes = result.files.single.bytes!;
      final ext = result.files.single.extension ?? 'pdf';
      final ref = _storage
          .ref()
          .child(AppConsts.storageTimetables)
          .child('custom_${_groupId}_${DateTime.now().millisecondsSinceEpoch}.$ext');

      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      await _groupCtrl.updateTimetableUrl(_groupId, url);

      // Notify
      await NotificationService.instance.sendGroupNotification(
        groupId: _groupId,
        title: '📅 Timetable Updated!',
        body: 'A new match schedule has been uploaded. Check it now!',
        type: 'timetable',
      );

      Get.snackbar('Uploaded', 'Timetable uploaded and shared!');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
