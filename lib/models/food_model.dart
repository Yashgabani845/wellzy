import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final String brand; // e.g. "Generic"
  final String category;
  final List<String> aliases;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double defaultServingGrams;
  final bool isVegetarian;
  final bool isJain;
  final String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    this.brand = 'Generic',
    required this.category,
    this.aliases = const [],
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.defaultServingGrams = 100,
    this.isVegetarian = false,
    this.isJain = false,
    this.imageUrl,
  });

  // Calculate macros for any given weight
  double caloriesFor(double grams) => (caloriesPer100g / 100) * grams;
  double proteinFor(double grams) => (proteinPer100g / 100) * grams;
  double carbsFor(double grams) => (carbsPer100g / 100) * grams;
  double fatFor(double grams) => (fatPer100g / 100) * grams;

  factory FoodItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    // If it's from MongoDB (or matching schema)
    final nutrition = map['nutrition_per_100g'] as Map<String, dynamic>?;
    final dietary = map['dietary'] as Map<String, dynamic>?;
    final servingsList = map['servings'] as List<dynamic>?;
    double servingGrams = 100.0;
    if (servingsList != null && servingsList.isNotEmpty) {
      servingGrams = (servingsList[0]['weight_g'] as num?)?.toDouble() ?? 100.0;
    }

    return FoodItem(
      id: docId ?? map['food_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? 'Generic',
      category: map['category'] ?? '',
      aliases: (map['aliases'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      caloriesPer100g: (nutrition?['calories'] as num?)?.toDouble() ?? (map['caloriesPer100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (nutrition?['protein'] as num?)?.toDouble() ?? (map['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (nutrition?['carbs'] as num?)?.toDouble() ?? (map['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (nutrition?['fat'] as num?)?.toDouble() ?? (map['fatPer100g'] as num?)?.toDouble() ?? 0,
      fiberPer100g: (nutrition?['fiber'] as num?)?.toDouble() ?? (map['fiberPer100g'] as num?)?.toDouble() ?? 0,
      defaultServingGrams: (map['defaultServingGrams'] as num?)?.toDouble() ?? servingGrams,
      isVegetarian: dietary?['is_vegetarian'] ?? map['isVegetarian'] ?? false,
      isJain: dietary?['is_jain'] ?? map['isJain'] ?? false,
      imageUrl: map['image_url'] ?? map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'food_id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'aliases': aliases,
      'nutrition_per_100g': {
        'calories': caloriesPer100g,
        'protein': proteinPer100g,
        'carbs': carbsPer100g,
        'fat': fatPer100g,
        'fiber': fiberPer100g,
      },
      'dietary': {
        'is_vegetarian': isVegetarian,
        'is_jain': isJain,
      },
      'defaultServingGrams': defaultServingGrams,
      'image_url': imageUrl,
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
