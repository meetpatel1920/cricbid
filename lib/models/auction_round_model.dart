import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionRoundModel {
  final String id;
  final String auctionId;
  final String groupId;
  final int roundNumber;
  final List<String> playerIds; // ordered list of players in this round
  final int currentIndex;
  final String status; // pending, live, completed
  final String? pdfUrl;
  final DateTime createdAt;

  AuctionRoundModel({
    required this.id,
    required this.auctionId,
    required this.groupId,
    required this.roundNumber,
    required this.playerIds,
    this.currentIndex = 0,
    this.status = 'pending',
    this.pdfUrl,
    required this.createdAt,
  });

  factory AuctionRoundModel.fromMap(Map<String, dynamic> map, String id) {
    return AuctionRoundModel(
      id: id,
      auctionId: map['auctionId'] ?? '',
      groupId: map['groupId'] ?? '',
      roundNumber: map['roundNumber'] ?? 1,
      playerIds: List<String>.from(map['playerIds'] ?? []),
      currentIndex: map['currentIndex'] ?? 0,
      status: map['status'] ?? 'pending',
      pdfUrl: map['pdfUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'auctionId': auctionId,
        'groupId': groupId,
        'roundNumber': roundNumber,
        'playerIds': playerIds,
        'currentIndex': currentIndex,
        'status': status,
        'pdfUrl': pdfUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  String? get currentPlayerId => currentIndex < playerIds.length ? playerIds[currentIndex] : null;

  bool get isCompleted => currentIndex >= playerIds.length;
}
