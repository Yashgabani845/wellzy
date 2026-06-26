import 'package:healthify/models/food_model.dart';

class FoodService {
  // Mock food database — replace with real API search
  final List<FoodItem> _foodDatabase = [
    // Fruits
    FoodItem(id: 'f1', name: 'Banana', brand: 'Generic', category: 'Fruits', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 22.8, fatPer100g: 0.3, fiberPer100g: 2.6, defaultServingGrams: 118),
    FoodItem(id: 'f2', name: 'Apple', brand: 'Generic', category: 'Fruits', caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 13.8, fatPer100g: 0.2, fiberPer100g: 2.4, defaultServingGrams: 182),
    FoodItem(id: 'f3', name: 'Mango', brand: 'Generic', category: 'Fruits', caloriesPer100g: 60, proteinPer100g: 0.8, carbsPer100g: 15.0, fatPer100g: 0.4, fiberPer100g: 1.6, defaultServingGrams: 200),
    // Grains
    FoodItem(id: 'g1', name: 'White Rice (Cooked)', brand: 'Generic', category: 'Grains', caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28.2, fatPer100g: 0.3, defaultServingGrams: 150),
    FoodItem(id: 'g2', name: 'Brown Rice (Cooked)', brand: 'Generic', category: 'Grains', caloriesPer100g: 123, proteinPer100g: 2.7, carbsPer100g: 25.6, fatPer100g: 1.0, fiberPer100g: 1.6, defaultServingGrams: 150),
    FoodItem(id: 'g3', name: 'Oats', brand: 'Generic', category: 'Grains', caloriesPer100g: 389, proteinPer100g: 16.9, carbsPer100g: 66.3, fatPer100g: 6.9, fiberPer100g: 10.6, defaultServingGrams: 40),
    FoodItem(id: 'g4', name: 'Whole Wheat Bread', brand: 'Generic', category: 'Grains', caloriesPer100g: 247, proteinPer100g: 13.0, carbsPer100g: 41.0, fatPer100g: 3.4, fiberPer100g: 6.0, defaultServingGrams: 28),
    // Protein
    FoodItem(id: 'p1', name: 'Chicken Breast (Grilled)', brand: 'Generic', category: 'Protein', caloriesPer100g: 165, proteinPer100g: 31.0, carbsPer100g: 0.0, fatPer100g: 3.6, defaultServingGrams: 120),
    FoodItem(id: 'p2', name: 'Egg (Boiled)', brand: 'Generic', category: 'Protein', caloriesPer100g: 155, proteinPer100g: 12.6, carbsPer100g: 1.1, fatPer100g: 10.6, defaultServingGrams: 50),
    FoodItem(id: 'p3', name: 'Paneer', brand: 'Generic', category: 'Protein', caloriesPer100g: 265, proteinPer100g: 18.3, carbsPer100g: 1.2, fatPer100g: 20.8, defaultServingGrams: 100),
    FoodItem(id: 'p4', name: 'Tofu', brand: 'Generic', category: 'Protein', caloriesPer100g: 76, proteinPer100g: 8.0, carbsPer100g: 1.9, fatPer100g: 4.8, defaultServingGrams: 125),
    FoodItem(id: 'p5', name: 'Dal (Lentils Cooked)', brand: 'Generic', category: 'Protein', caloriesPer100g: 116, proteinPer100g: 9.0, carbsPer100g: 20.1, fatPer100g: 0.4, fiberPer100g: 7.9, defaultServingGrams: 150),
    // Dairy
    FoodItem(id: 'd1', name: 'Milk (Full Cream)', brand: 'Generic', category: 'Dairy', caloriesPer100g: 62, proteinPer100g: 3.2, carbsPer100g: 4.8, fatPer100g: 3.3, defaultServingGrams: 250),
    FoodItem(id: 'd2', name: 'Greek Yogurt', brand: 'Generic', category: 'Dairy', caloriesPer100g: 59, proteinPer100g: 10.0, carbsPer100g: 3.6, fatPer100g: 0.4, defaultServingGrams: 150),
    FoodItem(id: 'd3', name: 'Cheddar Cheese', brand: 'Generic', category: 'Dairy', caloriesPer100g: 403, proteinPer100g: 25.0, carbsPer100g: 1.3, fatPer100g: 33.1, defaultServingGrams: 28),
    // Snacks / Fast Food
    FoodItem(id: 's1', name: 'Samosa', brand: 'Generic', category: 'Snacks', caloriesPer100g: 262, proteinPer100g: 4.3, carbsPer100g: 28.8, fatPer100g: 14.6, defaultServingGrams: 80),
    FoodItem(id: 's2', name: 'Almonds', brand: 'Generic', category: 'Snacks', caloriesPer100g: 579, proteinPer100g: 21.2, carbsPer100g: 21.6, fatPer100g: 49.9, fiberPer100g: 12.5, defaultServingGrams: 28),
    FoodItem(id: 's3', name: 'Dark Chocolate (70%)', brand: 'Generic', category: 'Snacks', caloriesPer100g: 598, proteinPer100g: 7.8, carbsPer100g: 45.9, fatPer100g: 42.6, fiberPer100g: 10.9, defaultServingGrams: 30),
  ];

  // Search — replace with API call
  Future<List<FoodItem>> searchFood(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _foodDatabase
        .where((f) => f.name.toLowerCase().contains(lowerQuery) || f.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Recent / Recommended — replace with API call
  Future<List<FoodItem>> fetchRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return a subset as "frequently eaten"
    return [
      _foodDatabase[0],  // Banana
      _foodDatabase[3],  // White Rice
      _foodDatabase[7],  // Chicken Breast
      _foodDatabase[8],  // Egg
      _foodDatabase[5],  // Oats
      _foodDatabase[12], // Milk
    ];
  }

  // Log food — replace with API call
  Future<bool> logFood(FoodLogEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
