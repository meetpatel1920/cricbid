import 'package:cloud_firestore/cloud_firestore.dart';

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
