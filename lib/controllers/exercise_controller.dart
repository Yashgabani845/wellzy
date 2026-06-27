import 'package:get/get.dart';
import 'package:healthify/models/exercise_model.dart';
import 'package:healthify/services/exercise_service.dart';
import 'package:healthify/core/utils/refresh_data.dart';

class ExerciseController extends GetxController {
  final ExerciseService _service = ExerciseService();

  bool isLoading = true;
  bool isLogging = false;

  // Data from service
  List<ExerciseCategory> categories = [];
  ExerciseSummary? summary;

  // UI state
  int selectedCategoryIndex = 0;
  Exercise? selectedExercise;
  int durationMinutes = 30; // Default duration

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    update();

    try {
      final results = await Future.wait([
        _service.fetchExerciseCategories(),
        _service.fetchTodaySummary(),
      ]);
      categories = results[0] as List<ExerciseCategory>;
      summary = results[1] as ExerciseSummary;
    } catch (e) {
      categories = [];
      summary = null;
    } finally {
      isLoading = false;
      update();
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;
    selectedExercise = null;
    update();
  }

  void selectExercise(Exercise exercise) {
    selectedExercise = exercise;
    update();
  }

  void setDuration(int minutes) {
    durationMinutes = minutes;
    update();
  }

  int get estimatedCalories {
    if (selectedExercise == null) return 0;
    return selectedExercise!.caloriesPerMinute * durationMinutes;
  }

  List<Exercise> get currentExercises {
    if (categories.isEmpty) return [];
    return categories[selectedCategoryIndex].exercises;
  }

  int get totalCaloriesBurned => summary?.totalCaloriesBurned ?? 0;
  int get totalMinutes => summary?.totalMinutes ?? 0;
  int get dailyGoalCalories => summary?.dailyGoalCalories ?? 500;
  double get goalProgress => summary?.goalProgress ?? 0.0;
  List<ExerciseEntry> get todayEntries => summary?.todayEntries ?? [];

  Future<void> logExercise() async {
    if (selectedExercise == null) return;

    isLogging = true;
    update();

    try {
      await _service.logExercise(selectedExercise!, durationMinutes);
      RefreshData.refreshAll();

      // Update local state
      final entry = ExerciseEntry(
        exercise: selectedExercise!,
        durationMinutes: durationMinutes,
        date: DateTime.now(),
      );

      summary = ExerciseSummary(
        totalCaloriesBurned: totalCaloriesBurned + entry.caloriesBurned,
        totalMinutes: totalMinutes + durationMinutes,
        dailyGoalCalories: dailyGoalCalories,
        todayEntries: [...todayEntries, entry],
      );

      // Reset selection
      selectedExercise = null;
      durationMinutes = 30;
    } finally {
      isLogging = false;
      update();
    }
  }
}
