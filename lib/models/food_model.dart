import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory FoodItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return FoodItem(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (map['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (map['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (map['fatPer100g'] as num?)?.toDouble() ?? 0,
      fiberPer100g: (map['fiberPer100g'] as num?)?.toDouble() ?? 0,
      defaultServingGrams: (map['defaultServingGrams'] as num?)?.toDouble() ?? 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'defaultServingGrams': defaultServingGrams,
    };
  }
}

class FoodLogEntry {
  final String id;
  final String userId;
  final FoodItem food;
  final double servingGrams;
  final int servings;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime date;
  final String dateStr; // yyyy-MM-dd

  FoodLogEntry({
    this.id = '',
    this.userId = '',
    required this.food,
    required this.servingGrams,
    this.servings = 1,
    required this.mealType,
    required this.date,
    this.dateStr = '',
  });

  double get totalGrams => servingGrams * servings;
  double get totalCalories => food.caloriesFor(totalGrams);
  double get totalProtein => food.proteinFor(totalGrams);
  double get totalCarbs => food.carbsFor(totalGrams);
  double get totalFat => food.fatFor(totalGrams);

  factory FoodLogEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return FoodLogEntry(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      food: FoodItem.fromMap(map['food'] ?? {}),
      servingGrams: (map['servingGrams'] as num?)?.toDouble() ?? 100,
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      mealType: map['mealType'] ?? 'snack',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateStr: map['dateStr'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'food': food.toMap(),
      'servingGrams': servingGrams,
      'servings': servings,
      'mealType': mealType,
      'date': date,
      'dateStr': dateStr,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'food': food.toMap(),
      'servingGrams': servingGrams,
      'servings': servings,
      'mealType': mealType,
      'date': FieldValue.serverTimestamp(),
      'dateStr': dateStr,
    };
  }
}
