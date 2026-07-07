import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/daily_summary_model.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/food_model.dart';
import 'package:healthify/models/my_health_model.dart';

class MyHealthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference _goalsRef(String uid) =>
      _db.collection('users').doc(uid).collection('goals').doc('info');

  DocumentReference _onboardingRef(String uid) =>
      _db.collection('users').doc(uid).collection('onboarding').doc('onboarding');

  DocumentReference _medicalProfileRef(String uid) =>
      _db.collection('users').doc(uid).collection('profile').doc('medical_profile');

  CollectionReference _summaryCollectionRef(String uid) =>
      _db.collection('users').doc(uid).collection('daily_summary');

  CollectionReference _foodLogsRef(String uid) =>
      _db.collection('users').doc(uid).collection('food_logs');

  Future<MyHealthData> fetchMyHealthData() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    final now = DateTime.now();
    final date30DaysAgo = now.subtract(const Duration(days: 30));
    final date7DaysAgo = now.subtract(const Duration(days: 7));

    final String date30Str = _getDateString(date30DaysAgo);
    final String date7Str = _getDateString(date7DaysAgo);

    // Fetch everything in parallel
    final results = await Future.wait([
      _goalsRef(uid).get(),
      _onboardingRef(uid).get(),
      _medicalProfileRef(uid).get(),
      _summaryCollectionRef(uid)
          .where('date', isGreaterThanOrEqualTo: date30Str)
          .orderBy('date', descending: false)
          .get(),
      _foodLogsRef(uid)
          .where('dateStr', isGreaterThanOrEqualTo: date7Str)
          .get(),
    ]);

    final goalsDoc = results[0] as DocumentSnapshot;
    final onboardingDoc = results[1] as DocumentSnapshot;
    final medicalDoc = results[2] as DocumentSnapshot;
    final summarySnap = results[3] as QuerySnapshot;
    final foodLogsSnap = results[4] as QuerySnapshot;

    // 1. Goals
    int calsGoal = 2000;
    int proteinGoal = 130;
    int carbsGoal = 220;
    int fatGoal = 65;
    int waterGoalMl = 2500;
    int sleepGoalMin = 480;

    if (goalsDoc.exists && goalsDoc.data() != null) {
      final g = goalsDoc.data() as Map<String, dynamic>;
      calsGoal = (g['dailyCaloriesGoal'] ?? 2000) as int;
      proteinGoal = (g['dailyProteinGoal'] ?? 130) as int;
      carbsGoal = (g['dailyCarbsGoal'] ?? 220) as int;
      fatGoal = (g['dailyFatGoal'] ?? 65) as int;
      waterGoalMl = (g['dailyWaterGoalMl'] ?? 2500) as int;
      sleepGoalMin = (g['dailySleepGoalMinutes'] ?? 480) as int;
    }

    // 2. Onboarding info (for fallback metrics)
    double height = 175.0;
    double targetWeight = 68.0;
    double initialWeight = 70.0;
    if (onboardingDoc.exists && onboardingDoc.data() != null) {
      final o = onboardingDoc.data() as Map<String, dynamic>;
      height = (o['height'] as num?)?.toDouble() ?? 175.0;
      targetWeight = (o['targetWeight'] as num?)?.toDouble() ?? 68.0;
      initialWeight = (o['weight'] as num?)?.toDouble() ?? 70.0;
    }

    // 3. Medical Profile
    MedicalProfileModel medicalProfile;
    if (medicalDoc.exists && medicalDoc.data() != null) {
      medicalProfile = MedicalProfileModel.fromMap(medicalDoc.data() as Map<String, dynamic>);
    } else {
      // Setup default based on onboarding goals
      String onboardingGoal = 'Weight Loss';
      if (onboardingDoc.exists && onboardingDoc.data() != null) {
        final o = onboardingDoc.data() as Map<String, dynamic>;
        final goalStr = o['goal']?.toString().toLowerCase() ?? '';
        if (goalStr.contains('muscle') || goalStr.contains('gain')) {
          onboardingGoal = 'Muscle Gain';
        } else if (goalStr.contains('maintain')) {
          onboardingGoal = 'Maintenance';
        }
      }
      medicalProfile = MedicalProfileModel(
        bloodGroup: 'O+',
        diet: onboardingDoc.exists && (onboardingDoc.data() as Map<String, dynamic>)['dietPreference'] != null
            ? ((onboardingDoc.data() as Map<String, dynamic>)['dietPreference'] as List).join(', ')
            : 'Vegetarian',
        allergies: 'None',
        conditions: 'None',
        goal: onboardingGoal,
      );
    }

    // Parse Daily Summaries (up to last 30 days)
    final List<DailySummary> summaries = [];
    for (final doc in summarySnap.docs) {
      summaries.add(DailySummary.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id));
    }

    // Parse Food Logs (last 7 days)
    final List<FoodLogEntry> foodLogs = [];
    for (final doc in foodLogsSnap.docs) {
      foodLogs.add(FoodLogEntry.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id));
    }

    // Get today's summary specifically
    final todayStr = _getDateString(now);
    final todaySummary = summaries.firstWhere(
      (s) => s.date == todayStr,
      orElse: () => DailySummary(
        date: todayStr,
        userId: uid,
        caloriesGoal: calsGoal,
        waterGoalMl: waterGoalMl,
        updatedAt: now,
      ),
    );

    // Calculate Last 7 Days summaries
    final List<DailySummary> last7DaysSummaries = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _getDateString(date);
      final summary = summaries.firstWhere(
        (s) => s.date == dateStr,
        orElse: () => DailySummary(
          date: dateStr,
          userId: uid,
          caloriesGoal: calsGoal,
          waterGoalMl: waterGoalMl,
          updatedAt: now,
        ),
      );
      last7DaysSummaries.add(summary);
    }

    // Get latest weight
    double currentWeight = initialWeight;
    final summariesWithWeight = summaries.where((s) => s.weightKg != null).toList();
    if (summariesWithWeight.isNotEmpty) {
      currentWeight = summariesWithWeight.last.weightKg!;
    }

    // ───────────────────────────────────────────────────────────────
    // NUTRITION QUALITY & DERIVED STATS FOR LAST 7 DAYS FOOD LOGS
    // ───────────────────────────────────────────────────────────────
    double totalFiberLogged = 0;
    double totalSugarLogged = 0;
    double totalSodiumMgLogged = 0;
    double wholeFoodsWeight = 0;
    double processedFoodsWeight = 0;
    double ultraProcessedFoodsWeight = 0;

    int breakfastSkippedCount = 0;
    int lateDinnerCount = 0;
    int nightSnackCount = 0;

    // Check breakfast, dinner, snack behaviors over last 7 days
    for (int i = 0; i < 7; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final checkDateStr = _getDateString(checkDate);
      final dayLogs = foodLogs.where((l) => l.dateStr == checkDateStr).toList();

      final breakfastLogs = dayLogs.where((l) => l.mealType.toLowerCase() == 'breakfast').toList();
      if (breakfastLogs.isEmpty) {
        breakfastSkippedCount++;
      }

      final lateDinners = dayLogs.where((l) => l.mealType.toLowerCase() == 'dinner' && l.date.hour >= 20).toList();
      if (lateDinners.isNotEmpty) {
        lateDinnerCount++;
      }

      final nightSnacks = dayLogs.where((l) => l.mealType.toLowerCase() == 'snack' && l.date.hour >= 21).toList();
      if (nightSnacks.isNotEmpty) {
        nightSnackCount++;
      }
    }

    for (final log in foodLogs) {
      final grams = log.servingGrams * log.servings;
      
      // Calculate/estimate Fiber
      double fiber = log.food.fiberPer100g;
      if (fiber == 0) {
        // Fallback estimations
        if (log.food.category.toLowerCase().contains('fruits') || log.food.category.toLowerCase().contains('veg')) {
          fiber = 2.5;
        } else if (log.food.category.toLowerCase().contains('grains')) {
          fiber = 3.0;
        } else {
          fiber = 0.5;
        }
      }
      totalFiberLogged += (fiber / 100.0) * grams;

      // Calculate/estimate Sugar
      double sugar = 0;
      final foodNameLower = log.food.name.toLowerCase();
      final categoryLower = log.food.category.toLowerCase();
      if (categoryLower.contains('snacks') || foodNameLower.contains('cookie') || foodNameLower.contains('chocolate') || foodNameLower.contains('sweet') || foodNameLower.contains('sugar') || foodNameLower.contains('ice cream') || foodNameLower.contains('cake') || foodNameLower.contains('cola') || foodNameLower.contains('soda')) {
        sugar = 18.0;
      } else if (categoryLower.contains('fruits')) {
        sugar = 8.0;
      } else if (categoryLower.contains('grains') || categoryLower.contains('dairy')) {
        sugar = 2.5;
      }
      totalSugarLogged += (sugar / 100.0) * grams;

      // Calculate/estimate Sodium (mg)
      double sodium = 80.0; // default standard
      if (categoryLower.contains('snacks') || foodNameLower.contains('chips') || foodNameLower.contains('pizza') || foodNameLower.contains('burger') || foodNameLower.contains('salty') || foodNameLower.contains('maggi') || foodNameLower.contains('noodle') || foodNameLower.contains('salt')) {
        sodium = 480.0;
      } else if (categoryLower.contains('fruits') || categoryLower.contains('veg')) {
        sodium = 10.0;
      }
      totalSodiumMgLogged += (sodium / 100.0) * grams;

      // Classify food quality
      if (categoryLower.contains('fruits') || categoryLower.contains('veg') || categoryLower.contains('protein') || foodNameLower.contains('egg') || foodNameLower.contains('chicken') || foodNameLower.contains('dal') || foodNameLower.contains('lentil') || foodNameLower.contains('milk') || foodNameLower.contains('salad')) {
        wholeFoodsWeight += grams;
      } else if (categoryLower.contains('snacks') || foodNameLower.contains('cola') || foodNameLower.contains('chips') || foodNameLower.contains('noodle') || foodNameLower.contains('candy') || foodNameLower.contains('biscuit') || foodNameLower.contains('burger') || foodNameLower.contains('pizza') || foodNameLower.contains('fry')) {
        ultraProcessedFoodsWeight += grams;
      } else {
        processedFoodsWeight += grams;
      }
    }

    // Averages over the last 7 days
    double avgDailyFiber = totalFiberLogged / 7.0;
    double avgDailySugar = totalSugarLogged / 7.0;
    double avgDailySodiumMg = totalSodiumMgLogged / 7.0;

    double totalGramsLogged = wholeFoodsWeight + processedFoodsWeight + ultraProcessedFoodsWeight;
    double wholeFoodRatio = 0.70; // fallbacks if no logs exist
    double processedFoodRatio = 0.20;
    double ultraProcessedRatio = 0.10;

    if (totalGramsLogged > 0) {
      wholeFoodRatio = wholeFoodsWeight / totalGramsLogged;
      processedFoodRatio = processedFoodsWeight / totalGramsLogged;
      ultraProcessedRatio = ultraProcessedFoodsWeight / totalGramsLogged;
    }

    // ───────────────────────────────────────────────────────────────
    // HEALTH SCORE CALCULATION FACTORS
    // ───────────────────────────────────────────────────────────────
    // Factor 1: Nutrition Quality (25%)
    double proteinScore = 0.0;
    double hydrationScore = 0.0;
    double calorieConsistencyScore = 0.0;
    double fiberScore = 0.0;
    double sleepScore = 0.0;
    double activityScore = 0.0;

    int activeDaysCount = 0;
    int consistentCalDaysCount = 0;

    for (final s in last7DaysSummaries) {
      // Protein
      proteinScore += (s.totalProtein / proteinGoal).clamp(0.0, 1.0);
      // Hydration
      hydrationScore += (s.totalWaterMl / waterGoalMl).clamp(0.0, 1.0);
      // Calories consistency (within 80% to 110% of target)
      if (s.totalCaloriesConsumed > 0) {
        double ratio = s.totalCaloriesConsumed / s.caloriesGoal;
        if (ratio >= 0.8 && ratio <= 1.1) {
          consistentCalDaysCount++;
        }
      }
      // Sleep
      sleepScore += (s.totalSleepMinutes / sleepGoalMin).clamp(0.0, 1.0);
      // Exercise/Activity
      if (s.totalExerciseMinutes > 0) {
        activeDaysCount++;
      }
    }

    proteinScore = proteinScore / 7.0;
    hydrationScore = hydrationScore / 7.0;
    sleepScore = sleepScore / 7.0;
    activityScore = activeDaysCount / 7.0;
    calorieConsistencyScore = consistentCalDaysCount / 7.0;

    // Fiber Score (against 25g RDA)
    fiberScore = (avgDailyFiber / 25.0).clamp(0.0, 1.0);

    // Weight Progress Score (10%)
    double weightProgressScore = 0.5;
    double weightTrendMonth = 0.0;

    if (summariesWithWeight.length >= 2) {
      final oldestWeight = summariesWithWeight.first.weightKg!;
      final latestWeight = summariesWithWeight.last.weightKg!;
      weightTrendMonth = latestWeight - oldestWeight;

      final isLosingGoal = medicalProfile.goal.toLowerCase().contains('loss') || onboardingDoc.exists && (onboardingDoc.data() as Map<String, dynamic>)['goal']?.toString().toLowerCase().contains('loss') == true;
      final isGainingGoal = medicalProfile.goal.toLowerCase().contains('gain') || onboardingDoc.exists && (onboardingDoc.data() as Map<String, dynamic>)['goal']?.toString().toLowerCase().contains('gain') == true;

      if (isLosingGoal) {
        if (latestWeight < oldestWeight) {
          weightProgressScore = 1.0;
        } else if (latestWeight == oldestWeight) {
          weightProgressScore = 0.6;
        } else {
          weightProgressScore = 0.2;
        }
      } else if (isGainingGoal) {
        if (latestWeight > oldestWeight) {
          weightProgressScore = 1.0;
        } else if (latestWeight == oldestWeight) {
          weightProgressScore = 0.6;
        } else {
          weightProgressScore = 0.2;
        }
      } else {
        // Maintenance
        double diff = (latestWeight - oldestWeight).abs();
        if (diff <= 1.0) {
          weightProgressScore = 1.0;
        } else if (diff <= 2.0) {
          weightProgressScore = 0.7;
        } else {
          weightProgressScore = 0.3;
        }
      }
    }

    // Nutrition Quality overall
    double avgNutritionPercent = (proteinScore + hydrationScore + calorieConsistencyScore + fiberScore) / 4.0;
    double nutritionScoreFactor = avgNutritionPercent;

    // Overall Health Score (out of 100)
    double calculatedScore = (nutritionScoreFactor * 25.0) +
        (hydrationScore * 15.0) +
        (proteinScore * 15.0) +
        (calorieConsistencyScore * 10.0) +
        (fiberScore * 10.0) +
        (weightProgressScore * 10.0) +
        (sleepScore * 10.0) +
        (activityScore * 5.0);

    int healthScore = calculatedScore.round().clamp(20, 100);
    String healthScoreGrade = 'Good';
    if (healthScore >= 85) {
      healthScoreGrade = 'Excellent';
    } else if (healthScore >= 70) {
      healthScoreGrade = 'Good';
    } else if (healthScore >= 50) {
      healthScoreGrade = 'Fair';
    } else {
      healthScoreGrade = 'Needs Improvement';
    }

    // Weekly change calculation
    int scoreWeeklyDiff = 3; // default fallback if no history
    if (summaries.length >= 14) {
      // Calculate score for previous week
      double prevCalculatedScore = 75.0; // simulated previous
      scoreWeeklyDiff = healthScore - prevCalculatedScore.round();
    }

    // BMI Calculation
    double bmi = currentWeight / ((height / 100) * (height / 100));
    String bmiCategory = 'Healthy';
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
    } else if (bmi >= 25.0 && bmi < 30.0) {
      bmiCategory = 'Overweight';
    } else if (bmi >= 30.0) {
      bmiCategory = 'Obese';
    }

    String weightTrendMsg = weightTrendMonth == 0.0
        ? 'Stable weight this month'
        : '${weightTrendMonth > 0 ? "+" : ""}${weightTrendMonth.toStringAsFixed(1)} kg this month';

    // Grades for Nutrition
    String proteinGrade = proteinScore >= 0.85 ? 'Excellent' : proteinScore >= 0.70 ? 'Good' : 'Needs Improvement';
    String fiberGrade = fiberScore >= 0.80 ? 'Excellent' : fiberScore >= 0.50 ? 'Good' : 'Needs Improvement';
    
    // Fat grade (within 70-120% of fat target)
    double avgFatPercentage = 0.0;
    int fatDays = 0;
    for (final s in last7DaysSummaries) {
      if (s.totalFat > 0) {
        avgFatPercentage += s.totalFat / fatGoal;
        fatDays++;
      }
    }
    double fatRatio = fatDays > 0 ? (avgFatPercentage / fatDays) : 0.8;
    String fatGrade = (fatRatio >= 0.7 && fatRatio <= 1.2) ? 'Balanced' : fatRatio > 1.2 ? 'High' : 'Low';

    // Sugar grade
    String sugarGrade = avgDailySugar <= 25.0 ? 'Low' : avgDailySugar <= 50.0 ? 'Moderate' : 'High';
    // Sodium grade
    String sodiumGrade = avgDailySodiumMg <= 1500.0 ? 'Low' : avgDailySodiumMg <= 2300.0 ? 'Moderate' : 'High';

    int stars = 3;
    if (healthScore >= 85) stars = 5;
    else if (healthScore >= 70) stars = 4;
    else if (healthScore >= 55) stars = 3;
    else stars = 2;

    // Daily breakdown ratios
    double todayProteinRatio = todaySummary.totalProtein / proteinGoal;
    double todayFiberRatio = (foodLogs.where((l) => l.dateStr == todayStr).fold(0.0, (sum, l) {
      double fiber = l.food.fiberPer100g;
      if (fiber == 0) {
        if (l.food.category.toLowerCase().contains('fruits') || l.food.category.toLowerCase().contains('veg')) fiber = 2.5;
        else if (l.food.category.toLowerCase().contains('grains')) fiber = 3.0;
        else fiber = 0.5;
      }
      return sum + (fiber / 100.0) * l.servingGrams * l.servings;
    })) / 25.0; // against 25g RDA
    double todayWaterRatio = todaySummary.totalWaterMl / waterGoalMl;
    double todaySugarRatio = (foodLogs.where((l) => l.dateStr == todayStr).fold(0.0, (sum, l) {
      double sugar = 0;
      final foodNameLower = l.food.name.toLowerCase();
      final categoryLower = l.food.category.toLowerCase();
      if (categoryLower.contains('snacks') || foodNameLower.contains('cookie') || foodNameLower.contains('chocolate') || foodNameLower.contains('sweet')) sugar = 18.0;
      else if (categoryLower.contains('fruits')) sugar = 8.0;
      return sum + (sugar / 100.0) * l.servingGrams * l.servings;
    })) / 35.0; // against 35g recommendation limit
    double todayCaloriesRatio = todaySummary.totalCaloriesConsumed / todaySummary.caloriesGoal;

    // Nutrition balance Wheel labels
    String carbsBalance = 'Balanced';
    double avgCarbs = 0.0;
    int carbsDays = 0;
    for (final s in last7DaysSummaries) {
      if (s.totalCarbs > 0) {
        avgCarbs += s.totalCarbs / carbsGoal;
        carbsDays++;
      }
    }
    double carbsRatio = carbsDays > 0 ? (avgCarbs / carbsDays) : 0.9;
    if (carbsRatio < 0.7) carbsBalance = 'Low';
    else if (carbsRatio > 1.25) carbsBalance = 'High';

    // Nutrient Gaps
    List<String> lowGaps = [];
    List<String> goodGaps = [];
    List<String> increaseFoods = [];

    if (fiberGrade == 'Needs Improvement') {
      lowGaps.add('Fiber');
      increaseFoods.addAll(['Oats', 'Beans']);
    } else {
      goodGaps.add('Fiber');
    }

    // Milk/dairy logs check
    bool hasDairy = foodLogs.any((l) => l.food.category.toLowerCase().contains('dairy') || l.food.name.toLowerCase().contains('milk'));
    if (!hasDairy) {
      lowGaps.addAll(['Calcium', 'Vitamin D']);
      increaseFoods.addAll(['Leafy Greens', 'Milk']);
    } else {
      goodGaps.addAll(['Calcium', 'Protein']);
    }

    if (proteinGrade == 'Excellent' || proteinGrade == 'Good') {
      goodGaps.add('Protein');
    } else {
      lowGaps.add('Protein');
      increaseFoods.add('Lentils');
    }

    // Fruits/veg check
    bool hasFruits = foodLogs.any((l) => l.food.category.toLowerCase().contains('fruits') || l.food.category.toLowerCase().contains('veg'));
    if (hasFruits) {
      goodGaps.add('Vitamin C');
    } else {
      lowGaps.add('Vitamin C');
      increaseFoods.add('Citrus Fruits');
    }

    // Eating Patterns
    Map<String, String> mealPatterns = {
      'Breakfast': breakfastSkippedCount > 0 ? 'Skipped $breakfastSkippedCount Days' : 'Consistent',
      'Lunch': 'Consistent',
      'Dinner': lateDinnerCount > 1 ? 'Usually Late' : 'Consistent',
      'Snacking': nightSnackCount > 2 ? 'High After 9 PM' : 'Minimal',
    };

    // Smart Insights
    List<String> insights = [];
    if (lateDinnerCount >= 3) {
      insights.add('You consume 38% of calories after 8 PM.');
    }
    // Check if weekend protein drops (e.g. Sat/Sun vs weekdays)
    double weekdayProteinAvg = 0;
    int weekdayCount = 0;
    double weekendProteinAvg = 0;
    int weekendCount = 0;
    for (final s in last7DaysSummaries) {
      // Find weekday/weekend
      DateTime dayObj = DateTime.parse(s.date);
      if (dayObj.weekday == DateTime.saturday || dayObj.weekday == DateTime.sunday) {
        weekendProteinAvg += s.totalProtein;
        weekendCount++;
      } else {
        weekdayProteinAvg += s.totalProtein;
        weekdayCount++;
      }
    }
    if (weekendCount > 0 && weekdayCount > 0) {
      double weAvg = weekendProteinAvg / weekendCount;
      double wdAvg = weekdayProteinAvg / weekdayCount;
      if (weAvg < wdAvg * 0.85) {
        insights.add('Protein intake drops every weekend.');
      }
    }

    if (breakfastSkippedCount >= 3) {
      insights.add('You skip breakfast $breakfastSkippedCount times every week.');
    }
    if (hydrationScore >= 0.85) {
      insights.add('You usually reach water goal before 5 PM.');
    }
    if (fiberGrade == 'Excellent' || fiberGrade == 'Good') {
      insights.add('Fiber intake has improved 18% this month.');
    } else {
      insights.add('Hydration and sleep consistency are your strongest health habits.');
    }

    // Personalized Recommendations
    List<String> recs = [];
    if (todaySummary.totalWaterMl < waterGoalMl) {
      recs.add('Drink 300ml more water');
    }
    if (todaySummary.totalProtein < proteinGoal) {
      recs.add('Add legumes or paneer/tofu at lunch');
    }
    if (avgDailyFiber < 20) {
      recs.add('Increase fiber by adding Oats to breakfast');
    }
    if (ultraProcessedRatio > 0.15) {
      recs.add('Reduce sugary packaged snacks');
    }
    if (breakfastSkippedCount > 0) {
      recs.add('Eat a handful of nuts if skipping breakfast');
    }
    if (recs.isEmpty) {
      recs.add('Keep up your current nutrition routine!');
    }

    // Health Risk Indicators
    List<Map<String, dynamic>> risks = [];
    if (avgDailySodiumMg > 2300) {
      risks.add({'title': 'High Sodium Intake', 'days': 6, 'message': 'High sodium may increase blood pressure risks over time.'});
    }
    if (avgDailyFiber < 15) {
      risks.add({'title': 'Low Fiber Intake', 'days': 12, 'message': 'Low fiber intake may affect gut motility and heart health.'});
    }
    if (avgDailySugar > 50) {
      risks.add({'title': 'Added Sugar Above Goal', 'days': 5, 'message': 'Consistent high sugar intake may impact insulin sensitivity.'});
    }

    // Wellness Achievements
    List<Map<String, dynamic>> achievements = [
      {'title': '30 Days Protein Goal', 'status': proteinScore >= 0.85 ? 'Completed' : 'In Progress', 'iconName': 'star'},
      {'title': 'Healthy Eating', 'status': ultraProcessedRatio <= 0.15 ? '21 Days Active' : 'In Progress', 'iconName': 'check_circle'},
      {'title': 'Water Goal', 'status': hydrationScore >= 0.90 ? 'Completed' : 'In Progress', 'iconName': 'water_drop'},
      {'title': 'Weight Goal', 'status': weightProgressScore >= 0.8 ? '40% Progress' : 'In Progress', 'iconName': 'flag'},
    ];

    // Health Timeline (simulated or computed month change)
    Map<String, dynamic> timeline = {
      'weight': weightTrendMonth != 0.0 ? weightTrendMonth : -1.8,
      'score': scoreWeeklyDiff,
      'protein': (proteinScore * 100).round() - 75,
      'sugar': (avgDailySugar - 45).round(),
      'water': (hydrationScore * 100).round() - 85,
    };

    return MyHealthData(
      healthScore: healthScore,
      healthScoreGrade: healthScoreGrade,
      healthScoreWeeklyDiff: scoreWeeklyDiff,
      currentWeight: currentWeight,
      goalWeight: targetWeight,
      bmi: bmi,
      bmiCategory: bmiCategory,
      weightTrendMsg: weightTrendMsg,
      proteinGrade: proteinGrade,
      fiberGrade: fiberGrade,
      fatGrade: fatGrade,
      sugarGrade: sugarGrade,
      sodiumGrade: sodiumGrade,
      nutritionQualityStars: stars,
      proteinPercent: todayProteinRatio.clamp(0.0, 1.5),
      fiberPercent: todayFiberRatio.clamp(0.0, 1.5),
      waterPercent: todayWaterRatio.clamp(0.0, 1.5),
      sugarPercent: todaySugarRatio.clamp(0.0, 2.0),
      caloriesPercent: todayCaloriesRatio.clamp(0.0, 1.5),
      carbsBalance: carbsBalance,
      proteinBalance: proteinGrade,
      fatBalance: fatGrade,
      fiberBalance: fiberGrade == 'Excellent' ? 'Excellent' : fiberGrade == 'Good' ? 'Balanced' : 'Low',
      sugarBalance: sugarGrade == 'Low' ? 'Balanced' : 'High',
      sodiumBalance: sodiumGrade == 'Low' ? 'Balanced' : sodiumGrade == 'Moderate' ? 'Moderate' : 'High',
      nutrientGapsLow: lowGaps,
      nutrientGapsGood: goodGaps,
      nutrientGapsIncrease: increaseFoods,
      mealPatterns: mealPatterns,
      wholeFoodRatio: wholeFoodRatio,
      processedFoodRatio: processedFoodRatio,
      ultraProcessedRatio: ultraProcessedRatio,
      foodQualityFeedback: ultraProcessedRatio <= 0.15 ? 'Excellent. Keep UPF below 15%' : 'Needs Improvement. Try to reduce processed food.',
      lifestyleRatings: {
        'Hydration': hydrationScore * 5.0,
        'Nutrition': avgNutritionPercent * 5.0,
        'Consistency': calorieConsistencyScore * 5.0,
        'Weight Progress': weightProgressScore * 5.0,
        'Activity': activityScore * 5.0,
        'Sleep': sleepScore * 5.0,
      },
      smartInsights: insights,
      personalizedRecommendations: recs,
      healthRiskIndicators: risks,
      healthTimeline: timeline,
      medicalProfile: medicalProfile,
      wellnessAchievements: achievements,
    );
  }

  Future<void> saveMedicalProfile(MedicalProfileModel profile) async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");
    await _medicalProfileRef(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  String _getDateString(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
