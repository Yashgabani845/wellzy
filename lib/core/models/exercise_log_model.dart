import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLogEntry {
  final String id;
  final String userId;
  final String exerciseName;
  final String categoryName;
  final int durationMinutes;
  final int caloriesPerMinute;
  final int totalCaloriesBurned;
  final DateTime loggedAt;
  final String date; // yyyy-MM-dd

  ExerciseLogEntry({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.categoryName,
    required this.durationMinutes,
    required this.caloriesPerMinute,
    required this.totalCaloriesBurned,
    required this.loggedAt,
    required this.date,
  });

  factory ExerciseLogEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExerciseLogEntry(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      categoryName: map['categoryName'] ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      caloriesPerMinute: (map['caloriesPerMinute'] as num?)?.toInt() ?? 0,
      totalCaloriesBurned: (map['totalCaloriesBurned'] as num?)?.toInt() ?? 0,
      loggedAt: (map['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseName': exerciseName,
      'categoryName': categoryName,
      'durationMinutes': durationMinutes,
      'caloriesPerMinute': caloriesPerMinute,
      'totalCaloriesBurned': totalCaloriesBurned,
      'loggedAt': loggedAt,
      'date': date,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'exerciseName': exerciseName,
      'categoryName': categoryName,
      'durationMinutes': durationMinutes,
      'caloriesPerMinute': caloriesPerMinute,
      'totalCaloriesBurned': totalCaloriesBurned,
      'loggedAt': FieldValue.serverTimestamp(),
      'date': date,
    };
  }
}
