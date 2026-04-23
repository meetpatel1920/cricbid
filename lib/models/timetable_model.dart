import 'package:cloud_firestore/cloud_firestore.dart';

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
