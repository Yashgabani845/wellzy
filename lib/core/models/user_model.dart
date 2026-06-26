import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
