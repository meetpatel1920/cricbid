import 'package:cloud_firestore/cloud_firestore.dart';

class LiveAuctionState {
  final String groupId;
  final bool isLive;
  final String? currentPlayerId;
  final String? currentPlayerName;
  final String? currentPlayerType;
  final String? currentPlayerPhotoUrl;
  final int currentPlayerNumber;
  final int currentRound;
  final String? lastAction; // 'sold', 'skip', 'calling'
  final String? lastTeamName;
  final int? lastPoints;
  final DateTime updatedAt;

  LiveAuctionState({
    required this.groupId,
    required this.isLive,
    this.currentPlayerId,
    this.currentPlayerName,
    this.currentPlayerType,
    this.currentPlayerPhotoUrl,
    this.currentPlayerNumber = 0,
    this.currentRound = 1,
    this.lastAction,
    this.lastTeamName,
    this.lastPoints,
    required this.updatedAt,
  });

  factory LiveAuctionState.fromMap(Map<String, dynamic> map) {
    return LiveAuctionState(
      groupId: map['groupId'] ?? '',
      isLive: map['isLive'] ?? false,
      currentPlayerId: map['currentPlayerId'],
      currentPlayerName: map['currentPlayerName'],
      currentPlayerType: map['currentPlayerType'],
      currentPlayerPhotoUrl: map['currentPlayerPhotoUrl'],
      currentPlayerNumber: map['currentPlayerNumber'] ?? 0,
      currentRound: map['currentRound'] ?? 1,
      lastAction: map['lastAction'],
      lastTeamName: map['lastTeamName'],
      lastPoints: map['lastPoints'],
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'isLive': isLive,
        'currentPlayerId': currentPlayerId,
        'currentPlayerName': currentPlayerName,
        'currentPlayerType': currentPlayerType,
        'currentPlayerPhotoUrl': currentPlayerPhotoUrl,
        'currentPlayerNumber': currentPlayerNumber,
        'currentRound': currentRound,
        'lastAction': lastAction,
        'lastTeamName': lastTeamName,
        'lastPoints': lastPoints,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
