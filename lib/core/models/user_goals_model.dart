/// User's daily nutritional and activity goals.
/// Stored at: users/{uid}/goals/info
class UserGoals {
  final String userId;
  final int dailyCaloriesGoal;
  final int dailyProteinGoal;
  final int dailyCarbsGoal;
  final int dailyFatGoal;
  final int dailyWaterGoalMl;
  final int dailyExerciseGoalCalories;
  final int dailySleepGoalMinutes;
  final int estimatedTimelineWeeks;

  UserGoals({
    required this.userId,
    this.dailyCaloriesGoal = 2000,
    this.dailyProteinGoal = 120,
    this.dailyCarbsGoal = 250,
    this.dailyFatGoal = 65,
    this.dailyWaterGoalMl = 2500,
    this.dailyExerciseGoalCalories = 300,
    this.dailySleepGoalMinutes = 480, // 8 hours
    this.estimatedTimelineWeeks = 0,
  });

  factory UserGoals.fromMap(Map<String, dynamic> map, {String? userId}) {
    return UserGoals(
      userId: userId ?? map['userId'] ?? '',
      dailyCaloriesGoal: (map['dailyCaloriesGoal'] as num?)?.toInt() ?? 2000,
      dailyProteinGoal: (map['dailyProteinGoal'] as num?)?.toInt() ?? 120,
      dailyCarbsGoal: (map['dailyCarbsGoal'] as num?)?.toInt() ?? 250,
      dailyFatGoal: (map['dailyFatGoal'] as num?)?.toInt() ?? 65,
      dailyWaterGoalMl: (map['dailyWaterGoalMl'] as num?)?.toInt() ?? 2500,
      dailyExerciseGoalCalories: (map['dailyExerciseGoalCalories'] as num?)?.toInt() ?? 300,
      dailySleepGoalMinutes: (map['dailySleepGoalMinutes'] as num?)?.toInt() ?? 480,
      estimatedTimelineWeeks: (map['estimatedTimelineWeeks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dailyCaloriesGoal': dailyCaloriesGoal,
      'dailyProteinGoal': dailyProteinGoal,
      'dailyCarbsGoal': dailyCarbsGoal,
      'dailyFatGoal': dailyFatGoal,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'dailyExerciseGoalCalories': dailyExerciseGoalCalories,
      'dailySleepGoalMinutes': dailySleepGoalMinutes,
      'estimatedTimelineWeeks': estimatedTimelineWeeks,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'dailyCaloriesGoal': dailyCaloriesGoal,
      'dailyProteinGoal': dailyProteinGoal,
      'dailyCarbsGoal': dailyCarbsGoal,
      'dailyFatGoal': dailyFatGoal,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'dailyExerciseGoalCalories': dailyExerciseGoalCalories,
      'dailySleepGoalMinutes': dailySleepGoalMinutes,
      'estimatedTimelineWeeks': estimatedTimelineWeeks,
    };
  }
}
