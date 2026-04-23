import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String adminUid;
  final String adminPhone;
  final int totalPointsPerTeam;
  final int minPlayerPoints;
  final int maxPlayersPerTeam;
  final DateTime createdAt;
  final bool isAuctionLive;
  final String? currentAuctionId;
  final String? teamThemeColor; // hex
  final String? timetableUrl;

  GroupModel({
    required this.id,
    required this.name,
    required this.adminUid,
    required this.adminPhone,
    required this.totalPointsPerTeam,
    required this.minPlayerPoints,
    required this.maxPlayersPerTeam,
    required this.createdAt,
    this.isAuctionLive = false,
    this.currentAuctionId,
    this.teamThemeColor,
    this.timetableUrl,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      adminUid: map['adminUid'] ?? '',
      adminPhone: map['adminPhone'] ?? '',
      totalPointsPerTeam: map['totalPointsPerTeam'] ?? 100,
      minPlayerPoints: map['minPlayerPoints'] ?? 1,
      maxPlayersPerTeam: map['maxPlayersPerTeam'] ?? 15,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAuctionLive: map['isAuctionLive'] ?? false,
      currentAuctionId: map['currentAuctionId'],
      teamThemeColor: map['teamThemeColor'],
      timetableUrl: map['timetableUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'adminUid': adminUid,
        'adminPhone': adminPhone,
        'totalPointsPerTeam': totalPointsPerTeam,
        'minPlayerPoints': minPlayerPoints,
        'maxPlayersPerTeam': maxPlayersPerTeam,
        'createdAt': Timestamp.fromDate(createdAt),
        'isAuctionLive': isAuctionLive,
        'currentAuctionId': currentAuctionId,
        'teamThemeColor': teamThemeColor,
        'timetableUrl': timetableUrl,
      };

  GroupModel copyWith({
    String? name,
    bool? isAuctionLive,
    String? currentAuctionId,
    String? teamThemeColor,
    String? timetableUrl,
    int? totalPointsPerTeam,
    int? minPlayerPoints,
    int? maxPlayersPerTeam,
  }) {
    return GroupModel(
      id: id,
      name: name ?? this.name,
      adminUid: adminUid,
      adminPhone: adminPhone,
      totalPointsPerTeam: totalPointsPerTeam ?? this.totalPointsPerTeam,
      minPlayerPoints: minPlayerPoints ?? this.minPlayerPoints,
      maxPlayersPerTeam: maxPlayersPerTeam ?? this.maxPlayersPerTeam,
      createdAt: createdAt,
      isAuctionLive: isAuctionLive ?? this.isAuctionLive,
      currentAuctionId: currentAuctionId ?? this.currentAuctionId,
      teamThemeColor: teamThemeColor ?? this.teamThemeColor,
      timetableUrl: timetableUrl ?? this.timetableUrl,
    );
  }
}
