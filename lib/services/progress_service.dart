import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/daily_summary_model.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/progress_model.dart';

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _summaryRef(String uid) =>
      _db.collection('users').doc(uid).collection('daily_summary');

  Future<ProgressData> fetchProgressData(String timePeriod) async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    int daysCount = 7;
    if (timePeriod == 'Today') {
      daysCount = 1;
    } else if (timePeriod == 'Week' || timePeriod == 'Last 7 Days') {
      daysCount = 7;
    } else if (timePeriod == 'Month' || timePeriod == 'Last Month') {
      daysCount = 30;
    }

    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: daysCount - 1));
    final cutoffStr = "${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}";

    // Query daily summary documents in date range
    final snap = await _summaryRef(uid)
        .where('date', isGreaterThanOrEqualTo: cutoffStr)
        .orderBy('date', descending: false)
        .get();

    final List<WeightDataPoint> weightTrends = [];
    final List<NutritionDataPoint> nutritionTrends = [];

    int totalCals = 0;
    int totalWaterMl = 0;
    int summariesWithData = 0;
    int consistentDays = 0;

    double? firstWeight;
    double? lastWeight;

    // We generate data points for all days in the range. 
    // If we have a Firestore summary for a day, we use it; otherwise, we return a zeroed/default baseline.
    final Map<String, DailySummary> summaryMap = {};
    for (final doc in snap.docs) {
      final summary = DailySummary.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      summaryMap[summary.date] = summary;
    }

    for (int i = daysCount - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

      final summary = summaryMap[dateStr];

      if (summary != null) {
        summariesWithData++;
        totalCals += summary.totalCaloriesConsumed;
        totalWaterMl += summary.totalWaterMl;

        // Check consistency (e.g. met water target and was within calorie goals)
        bool metWater = summary.totalWaterMl >= summary.waterGoalMl;
        bool metCalories = summary.totalCaloriesConsumed > 0 && summary.totalCaloriesConsumed <= summary.caloriesGoal;
        if (metWater || metCalories) {
          consistentDays++;
        }

        nutritionTrends.add(NutritionDataPoint(
          day,
          summary.totalCaloriesConsumed,
          summary.caloriesGoal,
        ));

        if (summary.weightKg != null) {
          firstWeight ??= summary.weightKg;
          lastWeight = summary.weightKg;
          weightTrends.add(WeightDataPoint(day, summary.weightKg!));
        }
      } else {
        // Default empty point for dates with no logs logged
        nutritionTrends.add(NutritionDataPoint(day, 0, 2000));
      }
    }

    // Averages and delta calculation
    final avgCalories = summariesWithData > 0 ? (totalCals ~/ summariesWithData) : 0;
    final avgWaterLiters = summariesWithData > 0 
        ? ((totalWaterMl / summariesWithData) / 1000.0) 
        : 0.0;
        
    final netWeightChange = (firstWeight != null && lastWeight != null) 
        ? (lastWeight - firstWeight) 
        : 0.0;
        
    final consistencyPercentage = summariesWithData > 0 
        ? ((consistentDays / summariesWithData) * 100).round() 
        : 0;

    final summaryStats = ProgressSummary(
      avgCalories: avgCalories,
      avgWaterLiters: double.parse(avgWaterLiters.toStringAsFixed(1)),
      netWeightChange: double.parse(netWeightChange.toStringAsFixed(1)),
      consistencyPercentage: consistencyPercentage,
    );

    // If no weight data points exist at all, fetch initial onboarding weight
    if (weightTrends.isEmpty) {
      final onboardingDoc = await _db.collection('users').doc(uid).collection('onboarding').doc('onboarding').get();
      if (onboardingDoc.exists) {
        final initialWeight = (onboardingDoc.data()?['weight'] as num?)?.toDouble() ?? 70.0;
        weightTrends.add(WeightDataPoint(now, initialWeight));
      }
    }

    return ProgressData(
      weightTrends: weightTrends,
      nutritionTrends: nutritionTrends,
      summary: summaryStats,
    );
  }
}
