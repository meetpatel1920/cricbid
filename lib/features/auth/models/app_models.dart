import 'package:cloud_firestore/cloud_firestore.dart';

// ════════════════════════════════════════════════════════════
//  USER MODEL
// ════════════════════════════════════════════════════════════
class UserModel {
  final String uid;
  final String phone;
  final String name;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final Map<String, String> groupRoles; // groupId -> role

  UserModel({
    required this.uid,
    required this.phone,
    required this.name,
    this.photoUrl,
    this.fcmToken,
    required this.createdAt,
    this.groupRoles = const {},
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      groupRoles: Map<String, String>.from(map['groupRoles'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'phone': phone,
        'name': name,
        'photoUrl': photoUrl,
        'fcmToken': fcmToken,
        'createdAt': Timestamp.fromDate(createdAt),
        'groupRoles': groupRoles,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? fcmToken,
    Map<String, String>? groupRoles,
  }) {
    return UserModel(
      uid: uid,
      phone: phone,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      groupRoles: groupRoles ?? this.groupRoles,
    );
  }
}

// ════════════════════════════════════════════════════════════
//  GROUP MODEL
// ════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════
//  TEAM MODEL
// ════════════════════════════════════════════════════════════
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
      ownerBirthdate:
          (map['ownerBirthdate'] as Timestamp?)?.toDate(),
      ownerType: map['ownerType'] ?? 'Batting',
      ownerLastTeam: map['ownerLastTeam'],
      totalPoints: map['totalPoints'] ?? 100,
      spentPoints: map['spentPoints'] ?? 0,
      playerCount: map['playerCount'] ?? 0,
      logoUrl: map['logoUrl'],
      themeColor: map['themeColor'],
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'name': name,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'ownerUid': ownerUid,
        'ownerAddress': ownerAddress,
        'ownerBirthdate': ownerBirthdate != null
            ? Timestamp.fromDate(ownerBirthdate!)
            : null,
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

// ════════════════════════════════════════════════════════════
//  PLAYER MODEL
// ════════════════════════════════════════════════════════════
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
        'birthdate':
            birthdate != null ? Timestamp.fromDate(birthdate!) : null,
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

// ════════════════════════════════════════════════════════════
//  AUCTION MODEL
// ════════════════════════════════════════════════════════════
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
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
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

// ════════════════════════════════════════════════════════════
//  AUCTION ROUND MODEL
// ════════════════════════════════════════════════════════════
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

  String? get currentPlayerId =>
      currentIndex < playerIds.length ? playerIds[currentIndex] : null;

  bool get isCompleted => currentIndex >= playerIds.length;
}

// ════════════════════════════════════════════════════════════
//  BID / AUCTION EVENT MODEL
// ════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════
//  LIVE AUCTION STATE (Firestore realtime doc)
// ════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════
//  CHAT MESSAGE MODEL
// ════════════════════════════════════════════════════════════
class MessageModel {
  final String id;
  final String groupId;
  final String senderUid;
  final String senderName;
  final String? senderPhotoUrl;
  final String senderRole;
  final String text;
  final DateTime sentAt;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.groupId,
    required this.senderUid,
    required this.senderName,
    this.senderPhotoUrl,
    required this.senderRole,
    required this.text,
    required this.sentAt,
    this.isDeleted = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      groupId: map['groupId'] ?? '',
      senderUid: map['senderUid'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'],
      senderRole: map['senderRole'] ?? 'player',
      text: map['text'] ?? '',
      sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'senderUid': senderUid,
        'senderName': senderName,
        'senderPhotoUrl': senderPhotoUrl,
        'senderRole': senderRole,
        'text': text,
        'sentAt': FieldValue.serverTimestamp(),
        'isDeleted': isDeleted,
      };
}

// ════════════════════════════════════════════════════════════
//  TIMETABLE MODEL
// ════════════════════════════════════════════════════════════
class TimetableModel {
  final String id;
  final String groupId;
  final String name;
  final DateTime fromDate;
  final DateTime toDate;
  final int matchesPerDay;
  final bool useGroups;
  final int numGroups;
  final Map<String, List<String>> groupTeams; // groupName -> [teamIds]
  final String? pdfUrl;
  final DateTime createdAt;

  TimetableModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.fromDate,
    required this.toDate,
    required this.matchesPerDay,
    required this.useGroups,
    required this.numGroups,
    required this.groupTeams,
    this.pdfUrl,
    required this.createdAt,
  });

  factory TimetableModel.fromMap(Map<String, dynamic> map, String id) {
    final rawGroups = map['groupTeams'] as Map<String, dynamic>? ?? {};
    return TimetableModel(
      id: id,
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      fromDate: (map['fromDate'] as Timestamp).toDate(),
      toDate: (map['toDate'] as Timestamp).toDate(),
      matchesPerDay: map['matchesPerDay'] ?? 2,
      useGroups: map['useGroups'] ?? false,
      numGroups: map['numGroups'] ?? 1,
      groupTeams: rawGroups.map((k, v) => MapEntry(k, List<String>.from(v))),
      pdfUrl: map['pdfUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'name': name,
        'fromDate': Timestamp.fromDate(fromDate),
        'toDate': Timestamp.fromDate(toDate),
        'matchesPerDay': matchesPerDay,
        'useGroups': useGroups,
        'numGroups': numGroups,
        'groupTeams': groupTeams,
        'pdfUrl': pdfUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ════════════════════════════════════════════════════════════
//  MATCH MODEL
// ════════════════════════════════════════════════════════════
class MatchModel {
  final String id;
  final String groupId;
  final String timetableId;
  final String team1Id;
  final String team1Name;
  final String team2Id;
  final String team2Name;
  final String stage; // group_A, group_B, semi_final, final
  final int matchNumber;
  final DateTime scheduledAt;
  final String venue;
  final String status; // scheduled, live, completed
  final String? winnerId;
  final String? winnerName;

  MatchModel({
    required this.id,
    required this.groupId,
    required this.timetableId,
    required this.team1Id,
    required this.team1Name,
    required this.team2Id,
    required this.team2Name,
    required this.stage,
    required this.matchNumber,
    required this.scheduledAt,
    this.venue = 'TBD',
    this.status = 'scheduled',
    this.winnerId,
    this.winnerName,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      groupId: map['groupId'] ?? '',
      timetableId: map['timetableId'] ?? '',
      team1Id: map['team1Id'] ?? '',
      team1Name: map['team1Name'] ?? '',
      team2Id: map['team2Id'] ?? '',
      team2Name: map['team2Name'] ?? '',
      stage: map['stage'] ?? 'group_A',
      matchNumber: map['matchNumber'] ?? 1,
      scheduledAt: (map['scheduledAt'] as Timestamp).toDate(),
      venue: map['venue'] ?? 'TBD',
      status: map['status'] ?? 'scheduled',
      winnerId: map['winnerId'],
      winnerName: map['winnerName'],
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'timetableId': timetableId,
        'team1Id': team1Id,
        'team1Name': team1Name,
        'team2Id': team2Id,
        'team2Name': team2Name,
        'stage': stage,
        'matchNumber': matchNumber,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'venue': venue,
        'status': status,
        'winnerId': winnerId,
        'winnerName': winnerName,
      };
}
