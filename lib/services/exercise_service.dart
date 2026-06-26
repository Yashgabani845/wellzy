import 'package:healthify/models/exercise_model.dart';

class ExerciseService {
  // Replace with real API call
  Future<ExerciseSummary> fetchTodaySummary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ExerciseSummary(
      totalCaloriesBurned: 180,
      totalMinutes: 35,
      dailyGoalCalories: 500,
      todayEntries: [
        ExerciseEntry(
          exercise: Exercise(id: '1', name: 'Morning Walk', caloriesPerMinute: 5, categoryId: 'cardio'),
          durationMinutes: 20,
          date: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        ExerciseEntry(
          exercise: Exercise(id: '2', name: 'Push Ups', caloriesPerMinute: 8, categoryId: 'strength'),
          durationMinutes: 15,
          date: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    );
  }

  // Replace with real API call
  Future<List<ExerciseCategory>> fetchExerciseCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ExerciseCategory(
        id: 'cardio',
        name: 'Cardio',
        icon: '🏃',
        exercises: [
          Exercise(id: 'c1', name: 'Running', caloriesPerMinute: 12, categoryId: 'cardio'),
          Exercise(id: 'c2', name: 'Walking', caloriesPerMinute: 5, categoryId: 'cardio'),
          Exercise(id: 'c3', name: 'Cycling', caloriesPerMinute: 10, categoryId: 'cardio'),
          Exercise(id: 'c4', name: 'Jump Rope', caloriesPerMinute: 14, categoryId: 'cardio'),
          Exercise(id: 'c5', name: 'Swimming', caloriesPerMinute: 11, categoryId: 'cardio'),
        ],
      ),
      ExerciseCategory(
        id: 'strength',
        name: 'Strength',
        icon: '💪',
        exercises: [
          Exercise(id: 's1', name: 'Push Ups', caloriesPerMinute: 8, categoryId: 'strength'),
          Exercise(id: 's2', name: 'Squats', caloriesPerMinute: 9, categoryId: 'strength'),
          Exercise(id: 's3', name: 'Deadlifts', caloriesPerMinute: 10, categoryId: 'strength'),
          Exercise(id: 's4', name: 'Bench Press', caloriesPerMinute: 8, categoryId: 'strength'),
          Exercise(id: 's5', name: 'Pull Ups', caloriesPerMinute: 9, categoryId: 'strength'),
        ],
      ),
      ExerciseCategory(
        id: 'flexibility',
        name: 'Flexibility',
        icon: '🧘',
        exercises: [
          Exercise(id: 'f1', name: 'Yoga', caloriesPerMinute: 4, categoryId: 'flexibility'),
          Exercise(id: 'f2', name: 'Stretching', caloriesPerMinute: 3, categoryId: 'flexibility'),
          Exercise(id: 'f3', name: 'Pilates', caloriesPerMinute: 6, categoryId: 'flexibility'),
        ],
      ),
      ExerciseCategory(
        id: 'sports',
        name: 'Sports',
        icon: '⚽',
        exercises: [
          Exercise(id: 'sp1', name: 'Basketball', caloriesPerMinute: 11, categoryId: 'sports'),
          Exercise(id: 'sp2', name: 'Tennis', caloriesPerMinute: 10, categoryId: 'sports'),
          Exercise(id: 'sp3', name: 'Football', caloriesPerMinute: 12, categoryId: 'sports'),
          Exercise(id: 'sp4', name: 'Badminton', caloriesPerMinute: 8, categoryId: 'sports'),
        ],
      ),
    ];
  }

  // Replace with real API call
  Future<bool> logExercise(Exercise exercise, int durationMinutes) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
