import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingModel {
  final bool completed;
  final DateTime? completedAt;
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;
  final double? targetWeight;
  final String? activityLevel;
  final String? goal;
  final List<String>? dietPreference;
  final int currentStep;

  OnboardingModel({
    required this.completed,
    this.completedAt,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.targetWeight,
    this.activityLevel,
    this.goal,
    this.dietPreference,
    required this.currentStep,
  });

  factory OnboardingModel.fromMap(Map<String, dynamic> map) {
    return OnboardingModel(
      completed: map['completed'] ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      gender: map['gender'],
      age: map['age'],
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      activityLevel: map['activityLevel'],
      goal: map['goal'],
      dietPreference: map['dietPreference'] != null
          ? List<String>.from(map['dietPreference'])
          : null,
      currentStep: map['currentStep'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completed': completed,
      'completedAt': completedAt,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'activityLevel': activityLevel,
      'goal': goal,
      'dietPreference': dietPreference,
      'currentStep': currentStep,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    final map = <String, dynamic>{
      'completed': completed,
      'currentStep': currentStep,
    };
    if (completed) {
      map['completedAt'] = FieldValue.serverTimestamp();
    }
    if (gender != null) map['gender'] = gender;
    if (age != null) map['age'] = age;
    if (height != null) map['height'] = height;
    if (weight != null) map['weight'] = weight;
    if (targetWeight != null) map['targetWeight'] = targetWeight;
    if (activityLevel != null) map['activityLevel'] = activityLevel;
    if (goal != null) map['goal'] = goal;
    if (dietPreference != null) map['dietPreference'] = dietPreference;
    return map;
  }
}
