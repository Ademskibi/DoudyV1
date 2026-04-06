import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? username;
  final String? photoUrl;
  final String role;
  final Timestamp? createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.username,
    this.photoUrl,
    required this.role,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      username: map['username'],
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'parent',
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (username != null) 'username': username,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? username,
    String? photoUrl,
    String? role,
    Timestamp? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
