import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionEventModel {
  final String id;
  final String auctionId;
  final String groupId;
  final String playerId;
  final String playerName;
  final int roundNumber;
  final String eventType; // sold, skipped, unsold
  final String? teamId;
  final String? teamName;
  final int? points;
  final DateTime timestamp;

  AuctionEventModel({
    required this.id,
    required this.auctionId,
    required this.groupId,
    required this.playerId,
    required this.playerName,
    required this.roundNumber,
    required this.eventType,
    this.teamId,
    this.teamName,
    this.points,
    required this.timestamp,
  });

  factory AuctionEventModel.fromMap(Map<String, dynamic> map, String id) {
    return AuctionEventModel(
      id: id,
      auctionId: map['auctionId'] ?? '',
      groupId: map['groupId'] ?? '',
      playerId: map['playerId'] ?? '',
      playerName: map['playerName'] ?? '',
      roundNumber: map['roundNumber'] ?? 1,
      eventType: map['eventType'] ?? 'pending',
      teamId: map['teamId'],
      teamName: map['teamName'],
      points: map['points'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'auctionId': auctionId,
        'groupId': groupId,
        'playerId': playerId,
        'playerName': playerName,
        'roundNumber': roundNumber,
        'eventType': eventType,
        'teamId': teamId,
        'teamName': teamName,
        'points': points,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
