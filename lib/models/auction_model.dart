import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionModel {
  final String id;
  final String groupId;
  final String status; // pending, live, paused, completed
  final int currentRound;
  final String? currentPlayerId;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  AuctionModel({
    required this.id,
    required this.groupId,
    required this.status,
    this.currentRound = 1,
    this.currentPlayerId,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  bool get isLive => status == 'live';
  bool get isPaused => status == 'paused';

  factory AuctionModel.fromMap(Map<String, dynamic> map, String id) {
    return AuctionModel(
      id: id,
      groupId: map['groupId'] ?? '',
      status: map['status'] ?? 'pending',
      currentRound: map['currentRound'] ?? 1,
      currentPlayerId: map['currentPlayerId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'status': status,
        'currentRound': currentRound,
        'currentPlayerId': currentPlayerId,
        'createdAt': Timestamp.fromDate(createdAt),
        'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };

  AuctionModel copyWith({
    String? status,
    int? currentRound,
    String? currentPlayerId,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return AuctionModel(
      id: id,
      groupId: groupId,
      status: status ?? this.status,
      currentRound: currentRound ?? this.currentRound,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
