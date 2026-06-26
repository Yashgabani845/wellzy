import 'package:healthify/models/progress_model.dart';
import 'dart:math';

class ProgressService {
  final Random _random = Random();

  Future<ProgressData> fetchProgressData(String timePeriod) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    int daysCount;
    if (timePeriod == 'Week') {
      daysCount = 7;
    } else if (timePeriod == 'Month') {
      daysCount = 30;
    } else {
      daysCount = 12; // We'll treat year as 12 data points for simplicity
    }

    final now = DateTime.now();
    final weightTrends = <WeightDataPoint>[];
    final nutritionTrends = <NutritionDataPoint>[];

    // Generate mock weight data trending downwards
    double currentWeight = 75.0; 
    for (int i = daysCount - 1; i >= 0; i--) {
      final date = timePeriod == 'Year' 
          ? DateTime(now.year, now.month - i, 1)
          : now.subtract(Duration(days: i));
      
      // Add some random fluctuation but generally trend down
      currentWeight -= _random.nextDouble() * 0.3;
      currentWeight += _random.nextDouble() * 0.2;
      
      weightTrends.add(WeightDataPoint(date, currentWeight));

      // Nutrition data
      final consumed = 1800 + _random.nextInt(600);
      nutritionTrends.add(NutritionDataPoint(date, consumed, 2100));
    }

    // Summary stats
    final summary = ProgressSummary(
      avgCalories: 2050,
      avgWaterLiters: 2.4,
      netWeightChange: weightTrends.last.weight - weightTrends.first.weight,
      consistencyPercentage: 85,
    );

    return ProgressData(
      weightTrends: weightTrends,
      nutritionTrends: nutritionTrends,
      summary: summary,
    );
  }
}
