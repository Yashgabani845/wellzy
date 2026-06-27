import 'package:cloud_firestore/cloud_firestore.dart';

/// Aggregated snapshot of a user's daily tracking data.
/// Document ID is the date string (yyyy-MM-dd).
class DailySummary {
  final String date; // yyyy-MM-dd (also the doc ID)
  final String userId;
  final int totalCaloriesConsumed;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final int totalWaterMl;
  final int totalExerciseCalories;
  final int totalExerciseMinutes;
  final int totalSleepMinutes;
  final double? weightKg;
  final int caloriesGoal;
  final int waterGoalMl;
  final DateTime updatedAt;

  DailySummary({
    required this.date,
    required this.userId,
    this.totalCaloriesConsumed = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.totalWaterMl = 0,
    this.totalExerciseCalories = 0,
    this.totalExerciseMinutes = 0,
    this.totalSleepMinutes = 0,
    this.weightKg,
    this.caloriesGoal = 2000,
    this.waterGoalMl = 2500,
    required this.updatedAt,
  });

  /// Computed progress ratios for the dashboard
  double get caloriesProgress =>
      caloriesGoal > 0 ? (totalCaloriesConsumed / caloriesGoal).clamp(0.0, 1.0) : 0.0;

  double get waterProgress =>
      waterGoalMl > 0 ? (totalWaterMl / waterGoalMl).clamp(0.0, 1.0) : 0.0;

  int get caloriesRemaining => caloriesGoal - totalCaloriesConsumed;
  int get waterRemaining => waterGoalMl - totalWaterMl;

  factory DailySummary.fromMap(Map<String, dynamic> map, {String? docId}) {
    return DailySummary(
      date: docId ?? map['date'] ?? '',
      userId: map['userId'] ?? '',
      totalCaloriesConsumed: (map['totalCaloriesConsumed'] as num?)?.toInt() ?? 0,
      totalProtein: (map['totalProtein'] as num?)?.toInt() ?? 0,
      totalCarbs: (map['totalCarbs'] as num?)?.toInt() ?? 0,
      totalFat: (map['totalFat'] as num?)?.toInt() ?? 0,
      totalWaterMl: (map['totalWaterMl'] as num?)?.toInt() ?? 0,
      totalExerciseCalories: (map['totalExerciseCalories'] as num?)?.toInt() ?? 0,
      totalExerciseMinutes: (map['totalExerciseMinutes'] as num?)?.toInt() ?? 0,
      totalSleepMinutes: (map['totalSleepMinutes'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      caloriesGoal: (map['caloriesGoal'] as num?)?.toInt() ?? 2000,
      waterGoalMl: (map['waterGoalMl'] as num?)?.toInt() ?? 2500,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'userId': userId,
      'totalCaloriesConsumed': totalCaloriesConsumed,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalWaterMl': totalWaterMl,
      'totalExerciseCalories': totalExerciseCalories,
      'totalExerciseMinutes': totalExerciseMinutes,
      'totalSleepMinutes': totalSleepMinutes,
      'weightKg': weightKg,
      'caloriesGoal': caloriesGoal,
      'waterGoalMl': waterGoalMl,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'date': date,
      'userId': userId,
      'totalCaloriesConsumed': totalCaloriesConsumed,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalWaterMl': totalWaterMl,
      'totalExerciseCalories': totalExerciseCalories,
      'totalExerciseMinutes': totalExerciseMinutes,
      'totalSleepMinutes': totalSleepMinutes,
      'weightKg': weightKg,
      'caloriesGoal': caloriesGoal,
      'waterGoalMl': waterGoalMl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
