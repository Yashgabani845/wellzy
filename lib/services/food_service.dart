import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/daily_summary_model.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/food_model.dart';

class FoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _foodLogsRef(String uid) =>
      _db.collection('users').doc(uid).collection('food_logs');

  DocumentReference _summaryRef(String uid, String date) =>
      _db.collection('users').doc(uid).collection('daily_summary').doc(date);

  DocumentReference _goalsRef(String uid) =>
      _db.collection('users').doc(uid).collection('goals').doc('info');

  String get _baseUrl {
    
    const part1 = 'aHR0cHM6Ly9mb29kZGF0YS';
    const part2 = '1zZXJ2ZXJsZXNzLnZlcmNlbC5hcHA=';
    return utf8.decode(base64.decode('$part1$part2'));
  }

  /// Searches for food in MongoDB using Vercel serverless backend.
  Future<List<FoodItem>> searchFood(String query, {bool isVeg = false, bool isJain = false}) async {
    try {
      if (query.isEmpty) return [];

      final url = Uri.parse('$_baseUrl/api/search?q=${Uri.encodeComponent(query)}&veg=$isVeg&jain=$isJain');
      print('[FoodService] GET $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => FoodItem.fromMap(map)).toList();
      } else {
        print('[FoodService] searchFood failed: status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[FoodService] searchFood error: $e');
      return [];
    }
  }

  /// Fetches default food items from MongoDB based on dietary filters and meal type.
  Future<List<FoodItem>> fetchRecommendations({
    bool isVeg = false,
    bool isJain = false,
    String mealType = 'breakfast',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/recommendations?mealType=$mealType&veg=$isVeg&jain=$isJain');
      print('[FoodService] GET $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((map) => FoodItem.fromMap(map)).toList();
      } else {
        print('[FoodService] fetchRecommendations failed: status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('[FoodService] fetchRecommendations error: $e');
      return [];
    }
  }

  /// Logs food item to Firestore and updates daily summary atomically.
  Future<bool> logFood(FoodLogEntry entry) async {
    final uid = await CurrentUser.getUid();
    if (uid == null) return false;

    final today = _getTodayDateString();
    final batch = _db.batch();

    // 1. Log the food entry
    final logDocRef = _foodLogsRef(uid).doc();
    final newEntry = FoodLogEntry(
      id: logDocRef.id,
      userId: uid,
      food: entry.food,
      servingGrams: entry.servingGrams,
      servings: entry.servings,
      mealType: entry.mealType,
      date: DateTime.now(),
      dateStr: today,
    );
    batch.set(logDocRef, newEntry.toFirestoreMap());

    // 2. Batch update/initialize daily_summary
    final summaryDoc = await _summaryRef(uid, today).get();
    
    final addCals = newEntry.totalCalories.round();
    final addProtein = newEntry.totalProtein.round();
    final addCarbs = newEntry.totalCarbs.round();
    final addFat = newEntry.totalFat.round();

    if (summaryDoc.exists) {
      batch.update(_summaryRef(uid, today), {
        'totalCaloriesConsumed': FieldValue.increment(addCals),
        'totalProtein': FieldValue.increment(addProtein),
        'totalCarbs': FieldValue.increment(addCarbs),
        'totalFat': FieldValue.increment(addFat),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Get goals for fallback targets
      final goalsDoc = await _goalsRef(uid).get();
      int waterGoal = 2500;
      int caloriesGoal = 2000;
      if (goalsDoc.exists && goalsDoc.data() != null) {
        final gData = goalsDoc.data() as Map<String, dynamic>?;
        waterGoal = (gData?['dailyWaterGoalMl'] ?? 2500) as int;
        caloriesGoal = (gData?['dailyCaloriesGoal'] ?? 2000) as int;
      }

      final summary = DailySummary(
        date: today,
        userId: uid,
        totalCaloriesConsumed: addCals,
        totalProtein: addProtein,
        totalCarbs: addCarbs,
        totalFat: addFat,
        waterGoalMl: waterGoal,
        caloriesGoal: caloriesGoal,
        updatedAt: DateTime.now(),
      );
      batch.set(_summaryRef(uid, today), summary.toFirestoreMap());
    }

    await batch.commit();
    return true;
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
