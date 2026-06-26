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
}

class Exercise {
  final String id;
  final String name;
  final int caloriesPerMinute; // Average kcal burned per minute
  final String categoryId;

  Exercise({
    required this.id,
    required this.name,
    required this.caloriesPerMinute,
    required this.categoryId,
  });
}

class ExerciseEntry {
  final Exercise exercise;
  final int durationMinutes;
  final DateTime date;

  ExerciseEntry({
    required this.exercise,
    required this.durationMinutes,
    required this.date,
  });

  int get caloriesBurned => exercise.caloriesPerMinute * durationMinutes;
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
