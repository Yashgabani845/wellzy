import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/daily_summary_model.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/dashboard_model.dart';
import 'package:healthify/models/food_model.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference _summaryRef(String uid, String date) =>
      _db.collection('users').doc(uid).collection('daily_summary').doc(date);

  CollectionReference _summaryCollectionRef(String uid) =>
      _db.collection('users').doc(uid).collection('daily_summary');

  DocumentReference _goalsRef(String uid) =>
      _db.collection('users').doc(uid).collection('goals').doc('info');

  CollectionReference _foodLogsRef(String uid) =>
      _db.collection('users').doc(uid).collection('food_logs');

  /// Fetches real dashboard data from Firestore daily summary, weight history, and today's meal logs.
  Future<DashboardModel> fetchDashboardData() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    final today = _getTodayDateString();
    
    // 1. Fetch user goals for fallback baselines
    final goalsDoc = await _goalsRef(uid).get();
    int calsGoal = 2000;
    int proteinGoal = 130;
    int carbsGoal = 220;
    int fatGoal = 65;
    int waterGoalMl = 2500;
    if (goalsDoc.exists && goalsDoc.data() != null) {
      final gData = goalsDoc.data() as Map<String, dynamic>;
      calsGoal = (gData['dailyCaloriesGoal'] ?? 2000) as int;
      proteinGoal = (gData['dailyProteinGoal'] ?? 130) as int;
      carbsGoal = (gData['dailyCarbsGoal'] ?? 220) as int;
      fatGoal = (gData['dailyFatGoal'] ?? 65) as int;
      waterGoalMl = (gData['dailyWaterGoalMl'] ?? 2500) as int;
    }

    // 2. Fetch today's Daily Summary
    final summaryDoc = await _summaryRef(uid, today).get();
    DailySummary summary;
    if (summaryDoc.exists && summaryDoc.data() != null) {
      summary = DailySummary.fromMap(summaryDoc.data() as Map<String, dynamic>, docId: today);
    } else {
      // Create empty fallback summary
      summary = DailySummary(
        date: today,
        userId: uid,
        caloriesGoal: calsGoal,
        waterGoalMl: waterGoalMl,
        updatedAt: DateTime.now(),
      );
    }

    // 3. Fetch weight history (last 5 entries for trend chart)
    final weightSnap = await _summaryCollectionRef(uid)
        .orderBy('date', descending: true)
        .limit(5)
        .get();

    final List<double> last5DaysWeights = [];
    double currentWeight = 70.0; // fallback default
    
    // Reverse weight list so it reads chronologically (left to right)
    final docs = weightSnap.docs.reversed.toList();
    for (final doc in docs) {
      final wData = doc.data() as Map<String, dynamic>?;
      final w = (wData?['weightKg'] as num?)?.toDouble();
      if (w != null) {
        last5DaysWeights.add(w);
        currentWeight = w;
      }
    }

    // If no daily summary weight was logged, check onboarding weight
    if (last5DaysWeights.isEmpty) {
      final onboardingDoc = await _db.collection('users').doc(uid).collection('onboarding').doc('onboarding').get();
      if (onboardingDoc.exists) {
        final oData = onboardingDoc.data() as Map<String, dynamic>?;
        final initialWeight = (oData?['weight'] as num?)?.toDouble() ?? 70.0;
        currentWeight = initialWeight;
        last5DaysWeights.add(initialWeight);
      }
    }

    // Ensure we have at least some historical points for graph rendering safety
    while (last5DaysWeights.length < 5) {
      last5DaysWeights.insert(0, currentWeight);
    }

    // 4. Query today's food logs to group and build Meal cards
    final foodLogsSnap = await _foodLogsRef(uid)
        .where('dateStr', isEqualTo: today)
        .get();

    final List<FoodLogEntry> todayFoodLogs = [];
    for (final doc in foodLogsSnap.docs) {
      todayFoodLogs.add(FoodLogEntry.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id));
    }

    // Organize logs into meals
    final meals = _buildMealCards(todayFoodLogs, calsGoal);

    final onboardingDoc = await _db.collection('users').doc(uid).collection('onboarding').doc('onboarding').get();
    String defaultAvatar = 'assets/images/avatar_male.png';
    if (onboardingDoc.exists && onboardingDoc.data() != null) {
      final oData = onboardingDoc.data() as Map<String, dynamic>;
      if (oData['gender']?.toString().toLowerCase() == 'female') {
        defaultAvatar = 'assets/images/avatar_female.png';
      }
    }

    final String userName = await CurrentUser.getName() ?? 'User';

    return DashboardModel(
      userName: userName,
      userAvatar: defaultAvatar,
      caloriesTarget: calsGoal,
      caloriesConsumed: summary.totalCaloriesConsumed,
      protein: MacroData(total: proteinGoal, consumed: summary.totalProtein),
      carbs: MacroData(total: carbsGoal, consumed: summary.totalCarbs),
      fat: MacroData(total: fatGoal, consumed: summary.totalFat),
      water: WaterData(total: summary.waterGoalMl / 1000.0, consumed: summary.totalWaterMl / 1000.0),
      weight: WeightData(
        current: currentWeight,
        last5Days: last5DaysWeights,
      ),
      meals: meals,
    );
  }

  List<Meal> _buildMealCards(List<FoodLogEntry> logs, int caloriesGoal) {
    // Standard targets distribution
    final breakfastTarget = (caloriesGoal * 0.3).round();
    final lunchTarget = (caloriesGoal * 0.4).round();
    final dinnerTarget = (caloriesGoal * 0.3).round();

    // Group logged entries
    final breakfastLogs = logs.where((l) => l.mealType.toLowerCase() == 'breakfast').toList();
    final lunchLogs = logs.where((l) => l.mealType.toLowerCase() == 'lunch').toList();
    final dinnerLogs = logs.where((l) => l.mealType.toLowerCase() == 'dinner').toList();

    return [
      _createMealCard('Breakfast', breakfastLogs, breakfastTarget, 'assets/images/meal_breakfast.png'),
      _createMealCard('Lunch', lunchLogs, lunchTarget, 'assets/images/meal_breakfast.png'), // Reuse image asset safely
      _createMealCard('Dinner', dinnerLogs, dinnerTarget, 'assets/images/meal_breakfast.png'),
    ];
  }

  Meal _createMealCard(String name, List<FoodLogEntry> mealLogs, int targetCalories, String imagePath) {
    if (mealLogs.isEmpty) {
      return Meal(
        id: name.toLowerCase(),
        name: name,
        description: 'Recommend $targetCalories kcal',
        calories: targetCalories,
        isCompleted: false,
      );
    }

    final int totalCals = mealLogs.fold(0, (sum, item) => sum + item.totalCalories.round());
    final int totalProtein = mealLogs.fold(0, (sum, item) => sum + item.totalProtein.round());
    final int totalCarbs = mealLogs.fold(0, (sum, item) => sum + item.totalCarbs.round());
    final int totalFat = mealLogs.fold(0, (sum, item) => sum + item.totalFat.round());

    // Join names (e.g. "Oatmeal, Banana")
    final names = mealLogs.map((l) => l.food.name).toSet().join(', ');

    return Meal(
      id: name.toLowerCase(),
      name: name,
      description: names,
      calories: totalCals,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      imagePath: imagePath,
      isCompleted: true,
    );
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
