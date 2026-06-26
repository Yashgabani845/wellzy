class FoodItem {
  final String id;
  final String name;
  final String brand; // e.g. "Generic", "McDonald's"
  final String category; // e.g. "Fruits", "Grains", "Dairy"
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double defaultServingGrams; // e.g. 1 apple = 182g

  FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.defaultServingGrams = 100,
  });

  // Calculate macros for any given weight
  double caloriesFor(double grams) => (caloriesPer100g / 100) * grams;
  double proteinFor(double grams) => (proteinPer100g / 100) * grams;
  double carbsFor(double grams) => (carbsPer100g / 100) * grams;
  double fatFor(double grams) => (fatPer100g / 100) * grams;
}

class FoodLogEntry {
  final FoodItem food;
  final double servingGrams;
  final int servings;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime date;

  FoodLogEntry({
    required this.food,
    required this.servingGrams,
    this.servings = 1,
    required this.mealType,
    required this.date,
  });

  double get totalGrams => servingGrams * servings;
  double get totalCalories => food.caloriesFor(totalGrams);
  double get totalProtein => food.proteinFor(totalGrams);
  double get totalCarbs => food.carbsFor(totalGrams);
  double get totalFat => food.fatFor(totalGrams);
}
