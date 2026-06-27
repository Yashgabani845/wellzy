import 'package:cloud_firestore/cloud_firestore.dart';

class WeightLogEntry {
  final String id;
  final String userId;
  final double weightKg;
  final double? bmi;
  final DateTime loggedAt;
  final String date; // yyyy-MM-dd

  WeightLogEntry({
    required this.id,
    required this.userId,
    required this.weightKg,
    this.bmi,
    required this.loggedAt,
    required this.date,
  });

  /// Calculate BMI given height in cm
  static double calculateBmi(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category string
  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  factory WeightLogEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return WeightLogEntry(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0,
      bmi: (map['bmi'] as num?)?.toDouble(),
      loggedAt: (map['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'weightKg': weightKg,
      'bmi': bmi,
      'loggedAt': loggedAt,
      'date': date,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'weightKg': weightKg,
      'bmi': bmi,
      'loggedAt': FieldValue.serverTimestamp(),
      'date': date,
    };
  }
}
