import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerModel {
  final String id;
  final String groupId;
  final String name;
  final String phone;
  final String? address;
  final DateTime? birthdate;
  final String type; // Batting, Bowling, All-Rounder
  final String? lastTeam;
  final String? photoUrl;
  final String? teamId; // assigned after auction
  final String? teamName;
  final int? soldPoints;
  final String auctionStatus; // pending, sold, skipped, unsold
  final int playerNumber; // assigned sequentially
  final String uid; // set when player logs in
  final DateTime createdAt;

  PlayerModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.phone,
    this.address,
    this.birthdate,
    required this.type,
    this.lastTeam,
    this.photoUrl,
    this.teamId,
    this.teamName,
    this.soldPoints,
    this.auctionStatus = 'pending',
    required this.playerNumber,
    this.uid = '',
    required this.createdAt,
  });

  bool get isSold => auctionStatus == 'sold';
  bool get isUnsold => auctionStatus == 'unsold';
  bool get isSkipped => auctionStatus == 'skipped';

  factory PlayerModel.fromMap(Map<String, dynamic> map, String id) {
    return PlayerModel(
      id: id,
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
      birthdate: (map['birthdate'] as Timestamp?)?.toDate(),
      type: map['type'] ?? 'Batting',
      lastTeam: map['lastTeam'],
      photoUrl: map['photoUrl'],
      teamId: map['teamId'],
      teamName: map['teamName'],
      soldPoints: map['soldPoints'],
      auctionStatus: map['auctionStatus'] ?? 'pending',
      playerNumber: map['playerNumber'] ?? 0,
      uid: map['uid'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'name': name,
        'phone': phone,
        'address': address,
        'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
        'type': type,
        'lastTeam': lastTeam,
        'photoUrl': photoUrl,
        'teamId': teamId,
        'teamName': teamName,
        'soldPoints': soldPoints,
        'auctionStatus': auctionStatus,
        'playerNumber': playerNumber,
        'uid': uid,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  PlayerModel copyWith({
    String? photoUrl,
    String? teamId,
    String? teamName,
    int? soldPoints,
    String? auctionStatus,
    String? uid,
  }) {
    return PlayerModel(
      id: id,
      groupId: groupId,
      name: name,
      phone: phone,
      address: address,
      birthdate: birthdate,
      type: type,
      lastTeam: lastTeam,
      photoUrl: photoUrl ?? this.photoUrl,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      soldPoints: soldPoints ?? this.soldPoints,
      auctionStatus: auctionStatus ?? this.auctionStatus,
      playerNumber: playerNumber,
      uid: uid ?? this.uid,
      createdAt: createdAt,
    );
  }
}
