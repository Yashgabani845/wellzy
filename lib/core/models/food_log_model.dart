import 'package:cloud_firestore/cloud_firestore.dart';

class FoodLogEntry {
  final String id;
  final String userId;
  final String foodName;
  final String brand;
  final String category;
  final String mealType; // breakfast, lunch, dinner, snack
  final double servingGrams;
  final int servings;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final DateTime loggedAt;
  final String date; // yyyy-MM-dd

  FoodLogEntry({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.brand,
    required this.category,
    required this.mealType,
    required this.servingGrams,
    this.servings = 1,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.loggedAt,
    required this.date,
  });

  /// Computed total grams consumed
  double get totalGrams => servingGrams * servings;

  factory FoodLogEntry.fromMap(Map<String, dynamic> map, {String? docId}) {
    return FoodLogEntry(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      foodName: map['foodName'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      mealType: map['mealType'] ?? 'snack',
      servingGrams: (map['servingGrams'] as num?)?.toDouble() ?? 100.0,
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (map['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (map['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (map['fatPer100g'] as num?)?.toDouble() ?? 0,
      fiberPer100g: (map['fiberPer100g'] as num?)?.toDouble() ?? 0,
      totalCalories: (map['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (map['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (map['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (map['totalFat'] as num?)?.toDouble() ?? 0,
      loggedAt: (map['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'foodName': foodName,
      'brand': brand,
      'category': category,
      'mealType': mealType,
      'servingGrams': servingGrams,
      'servings': servings,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'loggedAt': loggedAt,
      'date': date,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'foodName': foodName,
      'brand': brand,
      'category': category,
      'mealType': mealType,
      'servingGrams': servingGrams,
      'servings': servings,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'loggedAt': FieldValue.serverTimestamp(),
      'date': date,
    };
  }
}
