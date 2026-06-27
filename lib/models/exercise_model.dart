import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseCategory {
  final String id;
  final String name;
  final String icon; // emoji or icon name
  final List<Exercise> exercises;

  ExerciseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.exercises,
  });

  factory ExerciseCategory.fromMap(Map<String, dynamic> map, {String? docId}) {
    final exercisesList = (map['exercises'] as List? ?? [])
        .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
        .toList();
    return ExerciseCategory(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      exercises: exercisesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }
}

class Exercise {
  final String id;
  final String name;
  final int caloriesPerMinute; // Average kcal burned per minute
  final String categoryId;
  final String imageAsset;

  Exercise({
    required this.id,
    required this.name,
    required this.caloriesPerMinute,
    required this.categoryId,
    this.imageAsset = '',
  });

  factory Exercise.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Exercise(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      caloriesPerMinute: (map['caloriesPerMinute'] as num?)?.toInt() ?? 0,
      categoryId: map['categoryId'] ?? '',
      imageAsset: map['imageAsset'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'caloriesPerMinute': caloriesPerMinute,
      'categoryId': categoryId,
      'imageAsset': imageAsset,
    };
  }
}

class ExerciseEntry {
  final String id;
  final String userId;
  final Exercise exercise;
  final int durationMinutes;
  final DateTime date;
  final String dateStr;

  ExerciseEntry({
    this.id = '',
    this.userId = '',
    required this.exercise,
    required this.durationMinutes,
    required this.date,
    this.dateStr = '',
  });

  int get caloriesBurned => exercise.caloriesPerMinute * durationMinutes;

  factory ExerciseEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExerciseEntry(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      exercise: Exercise.fromMap(map['exercise'] ?? {}),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateStr: map['dateStr'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exercise': exercise.toMap(),
      'durationMinutes': durationMinutes,
      'date': date,
      'dateStr': dateStr,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'exercise': exercise.toMap(),
      'durationMinutes': durationMinutes,
      'date': FieldValue.serverTimestamp(),
      'dateStr': dateStr,
    };
  }
}

class ExerciseSummary {
  final int totalCaloriesBurned;
  final int totalMinutes;
  final int dailyGoalCalories;
  final List<ExerciseEntry> todayEntries;

  ExerciseSummary({
    required this.totalCaloriesBurned,
    required this.totalMinutes,
    required this.dailyGoalCalories,
    required this.todayEntries,
  });

  double get goalProgress => dailyGoalCalories > 0
      ? (totalCaloriesBurned / dailyGoalCalories).clamp(0.0, 1.0)
      : 0.0;
}
