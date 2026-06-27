import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/daily_summary_model.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/exercise_model.dart';

class ExerciseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _exerciseLogsRef(String uid) =>
      _db.collection('users').doc(uid).collection('exercise_logs');

  DocumentReference _summaryRef(String uid, String date) =>
      _db.collection('users').doc(uid).collection('daily_summary').doc(date);

  DocumentReference _goalsRef(String uid) =>
      _db.collection('users').doc(uid).collection('goals').doc('info');

  // Predefined Categories & Exercises list
  final List<ExerciseCategory> _categories = [
    ExerciseCategory(
      id: 'cardio',
      name: 'Cardio',
      icon: '🏃',
      exercises: [
        Exercise(id: 'c1', name: 'Running', caloriesPerMinute: 12, categoryId: 'cardio', imageAsset: 'assets/images/exercises/c1_running.png'),
        Exercise(id: 'c2', name: 'Walking', caloriesPerMinute: 5, categoryId: 'cardio', imageAsset: 'assets/images/exercises/c2_walking.png'),
        Exercise(id: 'c3', name: 'Cycling', caloriesPerMinute: 10, categoryId: 'cardio', imageAsset: 'assets/images/exercises/c3_cycling.png'),
        Exercise(id: 'c4', name: 'Jump Rope', caloriesPerMinute: 14, categoryId: 'cardio', imageAsset: 'assets/images/exercises/c4_jumprope.png'),
        Exercise(id: 'c5', name: 'Swimming', caloriesPerMinute: 11, categoryId: 'cardio', imageAsset: 'assets/images/exercises/c5_swimming.png'),
      ],
    ),
    ExerciseCategory(
      id: 'strength',
      name: 'Strength',
      icon: '💪',
      exercises: [
        Exercise(id: 's1', name: 'Push Ups', caloriesPerMinute: 8, categoryId: 'strength', imageAsset: 'assets/images/exercises/s1_pushups.png'),
        Exercise(id: 's2', name: 'Squats', caloriesPerMinute: 9, categoryId: 'strength', imageAsset: 'assets/images/exercises/s2_squats.png'),
        Exercise(id: 's3', name: 'Deadlifts', caloriesPerMinute: 10, categoryId: 'strength', imageAsset: 'assets/images/exercises/s3_deadlifts.png'),
        Exercise(id: 's4', name: 'Bench Press', caloriesPerMinute: 8, categoryId: 'strength', imageAsset: 'assets/images/exercises/s4_benchpress.png'),
        Exercise(id: 's5', name: 'Pull Ups', caloriesPerMinute: 9, categoryId: 'strength', imageAsset: 'assets/images/exercises/s5_pullups.png'),
      ],
    ),
    ExerciseCategory(
      id: 'flexibility',
      name: 'Flexibility',
      icon: '🧘',
      exercises: [
        Exercise(id: 'f1', name: 'Yoga', caloriesPerMinute: 4, categoryId: 'flexibility', imageAsset: 'assets/images/exercises/f1_yoga.png'),
        Exercise(id: 'f2', name: 'Stretching', caloriesPerMinute: 3, categoryId: 'flexibility', imageAsset: 'assets/images/exercises/f2_stretching.png'),
        Exercise(id: 'f3', name: 'Pilates', caloriesPerMinute: 6, categoryId: 'flexibility', imageAsset: 'assets/images/exercises/f3_pilates.png'),
      ],
    ),
    ExerciseCategory(
      id: 'sports',
      name: 'Sports',
      icon: '⚽',
      exercises: [
        Exercise(id: 'sp1', name: 'Basketball', caloriesPerMinute: 11, categoryId: 'sports', imageAsset: 'assets/images/exercises/sp1_basketball.png'),
        Exercise(id: 'sp2', name: 'Tennis', caloriesPerMinute: 10, categoryId: 'sports', imageAsset: 'assets/images/exercises/sp2_tennis.png'),
        Exercise(id: 'sp3', name: 'Football', caloriesPerMinute: 12, categoryId: 'sports'),
        Exercise(id: 'sp4', name: 'Badminton', caloriesPerMinute: 8, categoryId: 'sports'),
      ],
    ),
  ];

  /// Fetches today's exercise log summary.
  Future<ExerciseSummary> fetchTodaySummary() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    final today = _getTodayDateString();

    // 1. Fetch current exercise goal
    final goalsDoc = await _goalsRef(uid).get();
    int dailyGoalCalories = 300; // default
    if (goalsDoc.exists && goalsDoc.data() != null) {
      final gData = goalsDoc.data() as Map<String, dynamic>?;
      dailyGoalCalories = (gData?['dailyExerciseGoalCalories'] ?? 300) as int;
    }

    // 2. Query today's exercise log entries
    final snap = await _exerciseLogsRef(uid)
        .where('dateStr', isEqualTo: today)
        .get();

    final List<ExerciseEntry> todayEntries = [];
    int totalCalories = 0;
    int totalMinutes = 0;

    for (final doc in snap.docs) {
      final entry = ExerciseEntry.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      todayEntries.add(entry);
      totalCalories += entry.caloriesBurned;
      totalMinutes += entry.durationMinutes;
    }

    return ExerciseSummary(
      totalCaloriesBurned: totalCalories,
      totalMinutes: totalMinutes,
      dailyGoalCalories: dailyGoalCalories,
      todayEntries: todayEntries,
    );
  }

  /// Fetches the available exercise categories list.
  Future<List<ExerciseCategory>> fetchExerciseCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _categories;
  }

  /// Logs a new exercise and updates the summary atomically.
  Future<bool> logExercise(Exercise exercise, int durationMinutes) async {
    final uid = await CurrentUser.getUid();
    if (uid == null) return false;

    final today = _getTodayDateString();
    final batch = _db.batch();

    final caloriesBurned = exercise.caloriesPerMinute * durationMinutes;

    // 1. Add exercise log doc
    final logDocRef = _exerciseLogsRef(uid).doc();
    final entry = ExerciseEntry(
      id: logDocRef.id,
      userId: uid,
      exercise: exercise,
      durationMinutes: durationMinutes,
      date: DateTime.now(),
      dateStr: today,
    );
    batch.set(logDocRef, entry.toFirestoreMap());

    // 2. Batch update/initialize daily_summary
    final summaryDoc = await _summaryRef(uid, today).get();

    if (summaryDoc.exists) {
      batch.update(_summaryRef(uid, today), {
        'totalExerciseCalories': FieldValue.increment(caloriesBurned),
        'totalExerciseMinutes': FieldValue.increment(durationMinutes),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Get goals for fallback targets
      final goalsDoc = await _goalsRef(uid).get();
      int waterGoal = 2500;
      int caloriesGoal = 2000;
      if (goalsDoc.exists && goalsDoc.data() != null) {
        final gData = goalsDoc.data() as Map<String, dynamic>?;
        waterGoal = (gData?['dailyWaterGoalMl'] ?? 2500) as int;
        caloriesGoal = (gData?['dailyCaloriesGoal'] ?? 2000) as int;
      }

      final summary = DailySummary(
        date: today,
        userId: uid,
        totalExerciseCalories: caloriesBurned,
        totalExerciseMinutes: durationMinutes,
        waterGoalMl: waterGoal,
        caloriesGoal: caloriesGoal,
        updatedAt: DateTime.now(),
      );
      batch.set(_summaryRef(uid, today), summary.toFirestoreMap());
    }

    await batch.commit();
    return true;
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
