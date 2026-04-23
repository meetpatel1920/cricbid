import 'package:cloud_firestore/cloud_firestore.dart';

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
