import 'package:cloud_firestore/cloud_firestore.dart';

class WaterLogEntry {
  final String id;
  final String userId;
  final int amountMl;
  final DateTime loggedAt;
  final String date; // yyyy-MM-dd for querying

  WaterLogEntry({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
    required this.date,
  });

  factory WaterLogEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WaterLogEntry(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      amountMl: (map['amountMl'] as num?)?.toInt() ?? 0,
      loggedAt: (map['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amountMl': amountMl,
      'loggedAt': loggedAt,
      'date': date,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'amountMl': amountMl,
      'loggedAt': FieldValue.serverTimestamp(),
      'date': date,
    };
  }
}
