import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String id;
  final String groupId;
  final String name;
  final String ownerName;
  final String ownerPhone;
  final String ownerUid; // set when owner logs in
  final String? ownerAddress;
  final DateTime? ownerBirthdate;
  final String ownerType; // Batting, Bowling, All-Rounder
  final String? ownerLastTeam;
  final int totalPoints;
  final int spentPoints;
  final int playerCount;
  final String? logoUrl;
  final String? themeColor; // hex
  final DateTime createdAt;

  TeamModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.ownerName,
    required this.ownerPhone,
    this.ownerUid = '',
    this.ownerAddress,
    this.ownerBirthdate,
    required this.ownerType,
    this.ownerLastTeam,
    required this.totalPoints,
    this.spentPoints = 0,
    this.playerCount = 0,
    this.logoUrl,
    this.themeColor,
    required this.createdAt,
  });

  int get remainingPoints => totalPoints - spentPoints;
  int get remainingBudget => remainingPoints;

  /// Max single-player bid keeping min headroom for remaining slots
  int maxBidForPlayer(int remainingSlots, int minPlayerPoints) {
    if (remainingSlots <= 0) return 0;
    final reserveForOthers = (remainingSlots - 1) * minPlayerPoints;
    return remainingPoints - reserveForOthers;
  }

  factory TeamModel.fromMap(Map<String, dynamic> map, String id) {
    return TeamModel(
      id: id,
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerPhone: map['ownerPhone'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      ownerAddress: map['ownerAddress'],
      ownerBirthdate: (map['ownerBirthdate'] as Timestamp?)?.toDate(),
      ownerType: map['ownerType'] ?? 'Batting',
      ownerLastTeam: map['ownerLastTeam'],
      totalPoints: map['totalPoints'] ?? 100,
      spentPoints: map['spentPoints'] ?? 0,
      playerCount: map['playerCount'] ?? 0,
      logoUrl: map['logoUrl'],
      themeColor: map['themeColor'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'name': name,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'ownerUid': ownerUid,
        'ownerAddress': ownerAddress,
        'ownerBirthdate': ownerBirthdate != null ? Timestamp.fromDate(ownerBirthdate!) : null,
        'ownerType': ownerType,
        'ownerLastTeam': ownerLastTeam,
        'totalPoints': totalPoints,
        'spentPoints': spentPoints,
        'playerCount': playerCount,
        'logoUrl': logoUrl,
        'themeColor': themeColor,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  TeamModel copyWith({
    String? ownerUid,
    int? spentPoints,
    int? playerCount,
    String? logoUrl,
    String? themeColor,
    String? name,
  }) {
    return TeamModel(
      id: id,
      groupId: groupId,
      name: name ?? this.name,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      ownerUid: ownerUid ?? this.ownerUid,
      ownerAddress: ownerAddress,
      ownerBirthdate: ownerBirthdate,
      ownerType: ownerType,
      ownerLastTeam: ownerLastTeam,
      totalPoints: totalPoints,
      spentPoints: spentPoints ?? this.spentPoints,
      playerCount: playerCount ?? this.playerCount,
      logoUrl: logoUrl ?? this.logoUrl,
      themeColor: themeColor ?? this.themeColor,
      createdAt: createdAt,
    );
  }
}
