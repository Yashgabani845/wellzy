class MacroData {
  final int total;
  final int consumed;
  MacroData({required this.total, required this.consumed});

  int get remaining => total - consumed;
  double get progress => total > 0 ? (consumed / total).clamp(0.0, 1.0) : 0.0;
}

class WaterData {
  final double total;
  final double consumed;
  WaterData({required this.total, required this.consumed});

  double get progress => total > 0 ? (consumed / total).clamp(0.0, 1.0) : 0.0;
}

class WeightData {
  final double current;
  final List<double> last5Days;
  WeightData({required this.current, required this.last5Days});
}

class Meal {
  final String id;
  final String name;
  final String description;
  final int calories;
  final int? protein;
  final int? carbs;
  final int? fat;
  final String? imagePath;
  final bool isCompleted;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.imagePath,
    this.isCompleted = false,
  });
}

class DashboardModel {
  final String userName;
  final String userAvatar;
  final int caloriesTarget;
  final int caloriesConsumed;
  final MacroData protein;
  final MacroData carbs;
  final MacroData fat;
  final WaterData water;
  final WeightData weight;
  final List<Meal> meals;

  DashboardModel({
    required this.userName,
    required this.userAvatar,
    required this.caloriesTarget,
    required this.caloriesConsumed,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.water,
    required this.weight,
    required this.meals,
  });

  int get caloriesRemaining => caloriesTarget - caloriesConsumed;
  double get caloriesProgress => caloriesTarget > 0 ? (caloriesConsumed / caloriesTarget).clamp(0.0, 1.0) : 0.0;
}
