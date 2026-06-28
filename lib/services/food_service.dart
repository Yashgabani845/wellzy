import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
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

  mongo.Db? _mongoDb;
  mongo.DbCollection? _foodsCollection;

  Future<void> _initMongo() async {
    if (_mongoDb != null && _mongoDb!.isConnected) return;
    final uri = dotenv.env['MONGODB_URI'];
    if (uri == null) throw Exception('MONGODB_URI not found in .env');
    
    try {
      _mongoDb = await mongo.Db.create(uri);
      await _mongoDb!.open();
      _foodsCollection = _mongoDb!.collection('foods');
      print('[FoodService] MongoDB connected successfully to database: ${_mongoDb!.databaseName}');
    } catch (e) {
      print('[FoodService] MongoDB connection failed: $e');
      _mongoDb = null;
      _foodsCollection = null;
      rethrow;
    }
  }

  /// Searches for food in MongoDB using name, aliases, and search_tokens.
  Future<List<FoodItem>> searchFood(String query, {bool isVeg = false, bool isJain = false}) async {
    try {
      await _initMongo();
      if (query.isEmpty) return [];

      final escapedQuery = RegExp.escape(query);
      final regex = {r'$regex': escapedQuery, r'$options': 'i'};

      // Combine $or search with dietary filters using $and
      final List<Map<String, dynamic>> andConditions = [
        {
          r'$or': [
            {'name': regex},
            {'aliases': regex},
            {'search_tokens': regex},
            {'name_lower': regex},
          ]
        },
      ];

      if (isVeg) {
        andConditions.add({'dietary.is_vegetarian': true});
      }
      if (isJain) {
        andConditions.add({'dietary.is_jain': true});
      }

      final filter = <String, dynamic>{
        r'$and': andConditions,
      };

      print('[FoodService] Searching: "$query" | veg=$isVeg jain=$isJain | filter=$filter');
      // Pass map directly to find() — do NOT use where.raw() as it drops $or/$and structure
      final results = await _foodsCollection!
          .find(filter)
          .take(20)
          .toList();
      print('[FoodService] Found ${results.length} results');
      return results.map((map) => FoodItem.fromMap(map)).toList();
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
      await _initMongo();

      final List<Map<String, dynamic>> andConditions = [];

      // Dietary filters
      if (isVeg) {
        andConditions.add({'dietary.is_vegetarian': true});
      }
      if (isJain) {
        andConditions.add({'dietary.is_jain': true});
      }

      // Meal-type specific recommendations via tags & categories
      if (mealType == 'breakfast') {
        andConditions.add({'tags': 'breakfast'});
      } else if (mealType == 'lunch') {
        // Lunch: Rice, Dals, and main breads
        andConditions.add({
          r'$or': [
            {'tags': 'lunch'},
            {'tags': 'main-course'},
            {'category': {r'$in': ['Grains & Breads', 'Dals & Legumes']}}
          ]
        });
      } else if (mealType == 'dinner') {
        // Dinner: Vegetables, healthy curries, and lighter rotis
        andConditions.add({
          r'$or': [
            {'tags': 'dinner'},
            {'category': 'Vegetables'}
          ]
        });
      } else if (mealType == 'snack') {
        andConditions.add({
          r'$or': [
            {'tags': 'snack'},
            {'category': 'Snacks'}
          ]
        });
      }

      // Build final filter — empty andConditions means fetch all (no filter)
      final filter = andConditions.isNotEmpty
          ? <String, dynamic>{r'$and': andConditions}
          : <String, dynamic>{};

      print('[FoodService] Recommendations | mealType=$mealType veg=$isVeg jain=$isJain | filter=$filter');
      // Pass map directly to find() — do NOT use where.raw() as it drops $or/$and structure
      final results = await _foodsCollection!
          .find(filter)
          .take(20)
          .toList();
      print('[FoodService] Fetched ${results.length} recommendations');
      return results.map((map) => FoodItem.fromMap(map)).toList();
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
