import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteFood {
  final String id;
  final String userId;
  final String foodName;
  final String brand;
  final String category;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double defaultServingGrams;
  final DateTime addedAt;

  FavouriteFood({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.brand,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.defaultServingGrams = 100,
    required this.addedAt,
  });

  /// Quick calorie calculation for a given weight
  double caloriesFor(double grams) => (caloriesPer100g / 100) * grams;
  double proteinFor(double grams) => (proteinPer100g / 100) * grams;
  double carbsFor(double grams) => (carbsPer100g / 100) * grams;
  double fatFor(double grams) => (fatPer100g / 100) * grams;

  factory FavouriteFood.fromMap(Map<String, dynamic> map, {String? docId}) {
    return FavouriteFood(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      foodName: map['foodName'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (map['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (map['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (map['fatPer100g'] as num?)?.toDouble() ?? 0,
      fiberPer100g: (map['fiberPer100g'] as num?)?.toDouble() ?? 0,
      defaultServingGrams: (map['defaultServingGrams'] as num?)?.toDouble() ?? 100,
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'foodName': foodName,
      'brand': brand,
      'category': category,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'defaultServingGrams': defaultServingGrams,
      'addedAt': addedAt,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'foodName': foodName,
      'brand': brand,
      'category': category,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'defaultServingGrams': defaultServingGrams,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
