import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/consts/app_consts.dart';
import '../../services/notification_service.dart';
import '../../routes/app_routes.dart';
import '../../models/app_models.dart';
import '../auth/auth_controller.dart';
import '../group/group_controller.dart';
import '../player/player_controller.dart';
import '../team/team_controller.dart';

class AuctionController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController _authCtrl = Get.find<AuthController>();
  final GroupController _groupCtrl = Get.find<GroupController>();
  final PlayerController _playerCtrl = Get.find<PlayerController>();
  final TeamController _teamCtrl = Get.find<TeamController>();

  final Rx<AuctionModel?> currentAuction = Rx<AuctionModel?>(null);
  final Rx<AuctionRoundModel?> currentRound = Rx<AuctionRoundModel?>(null);
  final Rx<PlayerModel?> activePlayer = Rx<PlayerModel?>(null);
  final Rx<LiveAuctionState?> liveState = Rx<LiveAuctionState?>(null);
  final RxList<AuctionEventModel> eventHistory = <AuctionEventModel>[].obs;
  final RxList<AuctionRoundModel> rounds = <AuctionRoundModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Admin selection
  final RxString selectedTeamId = ''.obs;
  final RxInt selectedPoints = 0.obs;
  final RxString bidValidationError = ''.obs;

  String get _groupId => _authCtrl.currentGroupId.value;

  @override
  void onInit() {
    super.onInit();
    _listenToLiveState();
    _loadCurrentAuction();
    _loadEventHistory();
  }

  void _listenToLiveState() {
    if (_groupId.isEmpty) return;
    _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .collection('live_auction')
        .doc('state')
        .snapshots()
        .listen((snap) {
      if (snap.exists) {
        liveState.value = LiveAuctionState.fromMap(snap.data()!);
        _onLiveStateChanged(liveState.value!);
      }
    });
  }

  void _onLiveStateChanged(LiveAuctionState state) {
    if (state.currentPlayerId != null && state.currentPlayerId!.isNotEmpty) {
      final found = _playerCtrl.players
          .firstWhereOrNull((p) => p.id == state.currentPlayerId);
      activePlayer.value = found;
    }
  }

  Future<void> _loadCurrentAuction() async {
    if (_groupId.isEmpty) return;
    final group = _groupCtrl.group;
    if (group?.currentAuctionId == null) return;

    final doc = await _db
        .collection(AppConsts.colAuctions)
        .doc(group!.currentAuctionId)
        .get();
    if (doc.exists) {
      currentAuction.value = AuctionModel.fromMap(doc.data()!, doc.id);
      await _loadRounds(currentAuction.value!.id);
    }
  }

  Future<void> _loadRounds(String auctionId) async {
    final snap = await _db
        .collection(AppConsts.colAuctionRounds)
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('roundNumber')
        .get();
    rounds.value =
        snap.docs.map((d) => AuctionRoundModel.fromMap(d.data(), d.id)).toList();
    if (rounds.isNotEmpty) {
      currentRound.value = rounds.last;
    }
  }

  void _loadEventHistory() {
    if (_groupId.isEmpty) return;
    _db
        .collection(AppConsts.colBids)
        .where('groupId', isEqualTo: _groupId)
        .orderBy('timestamp', descending: true)
        .limit(200)
        .snapshots()
        .listen((snap) {
      eventHistory.value = snap.docs
          .map((d) => AuctionEventModel.fromMap(d.data(), d.id))
          .toList();
    });
  }

  // ── Start Auction (Round 1) ───────────────────────────────────────────────

  Future<void> startAuction() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final auctionId = const Uuid().v4();

      // Create auction doc
      final auction = AuctionModel(
        id: auctionId,
        groupId: _groupId,
        status: AppConsts.auctionStatusLive,
        currentRound: 1,
        createdAt: DateTime.now(),
        startedAt: DateTime.now(),
      );
      await _db
          .collection(AppConsts.colAuctions)
          .doc(auctionId)
          .set(auction.toMap());

      // Link to group
      await _db
          .collection(AppConsts.colGroups)
          .doc(_groupId)
          .update({'currentAuctionId': auctionId, 'isAuctionLive': true});

      currentAuction.value = auction;

      // Create Round 1 with all pending players, shuffled
      await createNextRound(auctionId: auctionId, roundNumber: 1);

      // Notify all group members
      await NotificationService.instance.sendGroupNotification(
        groupId: _groupId,
        title: '🏏 Auction is LIVE!',
        body: '${_groupCtrl.group?.name} auction has started. Open CricBid now!',
        type: 'auction_live',
      );

      Get.toNamed(AppRoutes.auctionLive);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create Next Round ────────────────────────────────────────────────────

  Future<void> createNextRound({
    String? auctionId,
    required int roundNumber,
  }) async {
    final id = auctionId ?? currentAuction.value?.id;
    if (id == null) return;

    await _playerCtrl.loadPlayers();

    // Get players for this round
    List<PlayerModel> roundPlayers;
    if (roundNumber == 1) {
      roundPlayers = List.from(_playerCtrl.players)..shuffle(Random());
    } else {
      // Unsold/skipped players go to next round, reshuffled
      roundPlayers = _playerCtrl.players
          .where((p) =>
              p.auctionStatus == AppConsts.playerStatusUnsold ||
              p.auctionStatus == AppConsts.playerStatusSkipped ||
              p.auctionStatus == AppConsts.playerStatusPending)
          .toList()
        ..shuffle(Random());
    }

    if (roundPlayers.isEmpty) {
      await _completeAuction(id);
      return;
    }

    final roundId = const Uuid().v4();
    final round = AuctionRoundModel(
      id: roundId,
      auctionId: id,
      groupId: _groupId,
      roundNumber: roundNumber,
      playerIds: roundPlayers.map((p) => p.id).toList(),
      createdAt: DateTime.now(),
      status: 'live',
    );

    await _db
        .collection(AppConsts.colAuctionRounds)
        .doc(roundId)
        .set(round.toMap());
    currentRound.value = round;
    rounds.add(round);

    // Set first player as active
    if (round.playerIds.isNotEmpty) {
      await _setActivePlayer(round.playerIds.first, roundNumber);
    }
  }

  // ── Set Active Player (broadcast to all) ─────────────────────────────────

  Future<void> _setActivePlayer(String playerId, int roundNumber) async {
    final player =
        _playerCtrl.players.firstWhereOrNull((p) => p.id == playerId);
    if (player == null) return;

    final state = LiveAuctionState(
      groupId: _groupId,
      isLive: true,
      currentPlayerId: playerId,
      currentPlayerName: player.name,
      currentPlayerType: player.type,
      currentPlayerPhotoUrl: player.photoUrl,
      currentPlayerNumber: player.playerNumber,
      currentRound: roundNumber,
      lastAction: 'calling',
      updatedAt: DateTime.now(),
    );

    await _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .collection('live_auction')
        .doc('state')
        .set(state.toMap());

    activePlayer.value = player;
  }

  // ── Sold ─────────────────────────────────────────────────────────────────

  Future<void> markSold({
    required String playerId,
    required String teamId,
    required String teamName,
    required int points,
  }) async {
    // Validate
    final team = _teamCtrl.teams.firstWhereOrNull((t) => t.id == teamId);
    if (team == null) return;

    final error = _teamCtrl.validateBid(
      team: team,
      bidPoints: points,
      minPlayerPoints: _groupCtrl.minPlayerPoints,
    );
    if (error != null) {
      bidValidationError.value = error;
      return;
    }

    isLoading.value = true;
    try {
      // Update player
      await _db.collection(AppConsts.colPlayers).doc(playerId).update({
        'auctionStatus': AppConsts.playerStatusSold,
        'teamId': teamId,
        'teamName': teamName,
        'soldPoints': points,
      });

      // Update team budget
      await _teamCtrl.recordPlayerSold(teamId, points, playerId);

      // Log event
      await _logEvent(
        playerId: playerId,
        eventType: 'sold',
        teamId: teamId,
        teamName: teamName,
        points: points,
      );

      // Broadcast sold animation
      final player =
          _playerCtrl.players.firstWhereOrNull((p) => p.id == playerId);
      await _db
          .collection(AppConsts.colGroups)
          .doc(_groupId)
          .collection('live_auction')
          .doc('state')
          .update({
        'lastAction': 'sold',
        'lastTeamName': teamName,
        'lastPoints': points,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify player
      final playerUid = player?.uid ?? '';
      if (playerUid.isNotEmpty) {
        await NotificationService.instance.sendUserNotification(
          uid: playerUid,
          title: '🎉 Congratulations!',
          body:
              'You have been sold to $teamName for $points points! Welcome to the team.',
          type: 'player_sold',
        );
      }

      // Notify owner
      final ownerUid = team.ownerUid;
      if (ownerUid.isNotEmpty) {
        await NotificationService.instance.sendUserNotification(
          uid: ownerUid,
          title: '🏆 Player Acquired!',
          body:
              'You have successfully bought ${player?.name ?? ''} for $points points. Well done!',
          type: 'player_bought',
        );
      }

      await _playerCtrl.loadPlayers();
      await _advanceToNextPlayer();
    } finally {
      isLoading.value = false;
      selectedTeamId.value = '';
      selectedPoints.value = 0;
      bidValidationError.value = '';
    }
  }

  // ── Skip ─────────────────────────────────────────────────────────────────

  Future<void> skipPlayer(String playerId) async {
    await _db.collection(AppConsts.colPlayers).doc(playerId).update({
      'auctionStatus': AppConsts.playerStatusSkipped,
    });

    await _logEvent(playerId: playerId, eventType: 'skipped');

    await _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .collection('live_auction')
        .doc('state')
        .update({
      'lastAction': 'skip',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _playerCtrl.loadPlayers();
    await _advanceToNextPlayer();
  }

  // ── Advance to Next Player ────────────────────────────────────────────────

  Future<void> _advanceToNextPlayer() async {
    final round = currentRound.value;
    if (round == null) return;

    final nextIndex = round.currentIndex + 1;
    if (nextIndex >= round.playerIds.length) {
      // Round complete
      await _db
          .collection(AppConsts.colAuctionRounds)
          .doc(round.id)
          .update({'status': 'completed', 'currentIndex': nextIndex});

      // Pause auction (admin manually starts next round)
      await _db
          .collection(AppConsts.colAuctions)
          .doc(currentAuction.value?.id)
          .update({'status': AppConsts.auctionStatusPaused});

      await _db
          .collection(AppConsts.colGroups)
          .doc(_groupId)
          .collection('live_auction')
          .doc('state')
          .update({
        'isLive': false,
        'lastAction': 'round_complete',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _db
          .collection(AppConsts.colGroups)
          .doc(_groupId)
          .update({'isAuctionLive': false});

      Get.snackbar('Round ${round.roundNumber} Complete',
          'Tap Start Next Round to continue');
    } else {
      await _db
          .collection(AppConsts.colAuctionRounds)
          .doc(round.id)
          .update({'currentIndex': nextIndex});
      currentRound.value = round.copyWith(currentIndex: nextIndex);
      await _setActivePlayer(
          round.playerIds[nextIndex], round.roundNumber);
    }
  }

  // ── Start Next Round ─────────────────────────────────────────────────────

  Future<void> startNextRound() async {
    final nextRound = (currentAuction.value?.currentRound ?? 1) + 1;
    await _db
        .collection(AppConsts.colAuctions)
        .doc(currentAuction.value?.id)
        .update({
      'status': AppConsts.auctionStatusLive,
      'currentRound': nextRound,
    });
    await _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .update({'isAuctionLive': true});

    await createNextRound(roundNumber: nextRound);
  }

  // ── Stop/Pause ────────────────────────────────────────────────────────────

  Future<void> pauseAuction() async {
    await _db
        .collection(AppConsts.colAuctions)
        .doc(currentAuction.value?.id)
        .update({'status': AppConsts.auctionStatusPaused});
    await _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .update({'isAuctionLive': false});
    await _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .collection('live_auction')
        .doc('state')
        .update({
      'isLive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resumeAuction() async {
    await _db
        .collection(AppConsts.colAuctions)
        .doc(currentAuction.value?.id)
        .update({'status': AppConsts.auctionStatusLive});
    await _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .update({'isAuctionLive': true});

    final round = currentRound.value;
    if (round != null && round.currentPlayerId != null) {
      await _setActivePlayer(
          round.currentPlayerId!, round.roundNumber);
    }
  }

  Future<void> _completeAuction(String auctionId) async {
    await _db
        .collection(AppConsts.colAuctions)
        .doc(auctionId)
        .update({
      'status': AppConsts.auctionStatusCompleted,
      'completedAt': FieldValue.serverTimestamp(),
    });
    await _db
        .collection(AppConsts.colGroups)
        .doc(_groupId)
        .update({'isAuctionLive': false});
    Get.snackbar('Auction Complete', 'All rounds finished!');
  }

  // ── Log Event ─────────────────────────────────────────────────────────────

  Future<void> _logEvent({
    required String playerId,
    required String eventType,
    String? teamId,
    String? teamName,
    int? points,
  }) async {
    final player =
        _playerCtrl.players.firstWhereOrNull((p) => p.id == playerId);
    final eventId = const Uuid().v4();
    final event = AuctionEventModel(
      id: eventId,
      auctionId: currentAuction.value?.id ?? '',
      groupId: _groupId,
      playerId: playerId,
      playerName: player?.name ?? '',
      roundNumber: currentRound.value?.roundNumber ?? 1,
      eventType: eventType,
      teamId: teamId,
      teamName: teamName,
      points: points,
      timestamp: DateTime.now(),
    );
    await _db
        .collection(AppConsts.colBids)
        .doc(eventId)
        .set(event.toMap());
  }

  // ── Validate Bid in real time ─────────────────────────────────────────────

  void onBidPointsChanged(int points) {
    selectedPoints.value = points;
    if (selectedTeamId.value.isEmpty) return;
    final team = _teamCtrl.teams
        .firstWhereOrNull((t) => t.id == selectedTeamId.value);
    if (team == null) return;
    bidValidationError.value = _teamCtrl.validateBid(
          team: team,
          bidPoints: points,
          minPlayerPoints: _groupCtrl.minPlayerPoints,
        ) ??
        '';
  }

  void onTeamSelected(String teamId) {
    selectedTeamId.value = teamId;
    bidValidationError.value = '';
    onBidPointsChanged(selectedPoints.value);
  }

  // Helpers
  AuctionRoundModel? copyWith(AuctionRoundModel r, {int? currentIndex}) {
    return AuctionRoundModel(
      id: r.id,
      auctionId: r.auctionId,
      groupId: r.groupId,
      roundNumber: r.roundNumber,
      playerIds: r.playerIds,
      currentIndex: currentIndex ?? r.currentIndex,
      status: r.status,
      pdfUrl: r.pdfUrl,
      createdAt: r.createdAt,
    );
  }
}

// Extension to make copyWith work
extension AuctionRoundExt on AuctionRoundModel {
  AuctionRoundModel copyWith({int? currentIndex, String? status}) {
    return AuctionRoundModel(
      id: id,
      auctionId: auctionId,
      groupId: groupId,
      roundNumber: roundNumber,
      playerIds: playerIds,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      pdfUrl: pdfUrl,
      createdAt: createdAt,
    );
  }
}

