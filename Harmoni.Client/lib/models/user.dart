import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final DateTime? createdAt;
  final String? profilePicturePath;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.createdAt,
    this.profilePicturePath,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
    String? profilePicturePath,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }

  factory AppUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data()!;
    return AppUser(
      id: snapshot.id,
      email: data['email'],
      username: data['username'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      profilePicturePath: data['profilePicturePath'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'profilePicturePath': profilePicturePath,
    };
  }
}