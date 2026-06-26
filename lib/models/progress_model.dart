class WeightDataPoint {
  final DateTime date;
  final double weight;

  WeightDataPoint(this.date, this.weight);
}

class NutritionDataPoint {
  final DateTime date;
  final int caloriesConsumed;
  final int calorieGoal;
  
  NutritionDataPoint(this.date, this.caloriesConsumed, this.calorieGoal);
  
  bool get isWithinGoal => caloriesConsumed <= calorieGoal;
}

class ProgressSummary {
  final int avgCalories;
  final double avgWaterLiters;
  final double netWeightChange; // Negative means lost weight
  final int consistencyPercentage; // 0-100

  ProgressSummary({
    required this.avgCalories,
    required this.avgWaterLiters,
    required this.netWeightChange,
    required this.consistencyPercentage,
  });
}

class ProgressData {
  final List<WeightDataPoint> weightTrends;
  final List<NutritionDataPoint> nutritionTrends;
  final ProgressSummary summary;
  
  ProgressData({
    required this.weightTrends,
    required this.nutritionTrends,
    required this.summary,
  });
}
