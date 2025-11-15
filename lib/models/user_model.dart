import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, admin }

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.user,
    DateTime? createdAt,
    this.updatedAt,
    this.phoneNumber,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? json['uid'] ?? '',
    email: json['email'] ?? '',
    displayName: json['displayName'],
    photoUrl: json['photoUrl'],
    role: json['role'] != null
        ? UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${json['role']}',
            orElse: () => UserRole.user,
          )
        : UserRole.user,
    createdAt: json['createdAt'] != null
        ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt']))
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
        : null,
    phoneNumber: json['phoneNumber'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': id,
    'email': email,
    if (displayName != null) 'displayName': displayName,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'role': role.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
