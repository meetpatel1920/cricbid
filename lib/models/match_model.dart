import 'package:cloud_firestore/cloud_firestore.dart';

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
