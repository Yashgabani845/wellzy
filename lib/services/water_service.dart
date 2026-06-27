import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/water_log_model.dart';
import 'package:healthify/core/models/daily_summary_model.dart';
import 'package:healthify/core/utils/current_user.dart';

class WaterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _waterLogsRef(String uid) =>
      _db.collection('users').doc(uid).collection('water_logs');

  DocumentReference _summaryRef(String uid, String date) =>
      _db.collection('users').doc(uid).collection('daily_summary').doc(date);

  DocumentReference _goalsRef(String uid) =>
      _db.collection('users').doc(uid).collection('goals').doc('info');

  /// Fetches today's accumulated water data.
  Future<Map<String, dynamic>> fetchWaterSummary() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    final today = _getTodayDateString();
    final summaryDoc = await _summaryRef(uid, today).get();

    if (summaryDoc.exists && summaryDoc.data() != null) {
      final summary = DailySummary.fromMap(summaryDoc.data() as Map<String, dynamic>, docId: today);
      return {
        'total': summary.waterGoalMl / 1000.0, // Convert to liters
        'consumed': summary.totalWaterMl / 1000.0,
      };
    }

    // Default fallback from goals
    final goalsDoc = await _goalsRef(uid).get();
    double targetLiters = 2.5;
    if (goalsDoc.exists && goalsDoc.data() != null) {
      final gData = goalsDoc.data() as Map<String, dynamic>?;
      targetLiters = ((gData?['dailyWaterGoalMl'] ?? 2500) as num).toDouble() / 1000.0;
    }

    return {
      'total': targetLiters,
      'consumed': 0.0,
    };
  }

  /// Logs a new water entry and updates the daily summary atomically using a Batch write.
  Future<bool> logWater(int amountMl) async {
    final uid = await CurrentUser.getUid();
    if (uid == null) return false;

    final today = _getTodayDateString();
    final batch = _db.batch();

    // 1. Create a new document reference in water_logs
    final logDocRef = _waterLogsRef(uid).doc();
    final entry = WaterLogEntry(
      id: logDocRef.id,
      userId: uid,
      amountMl: amountMl,
      loggedAt: DateTime.now(),
      date: today,
    );
    batch.set(logDocRef, entry.toFirestoreMap());

    // 2. Load and update/initialize daily_summary
    final summaryDoc = await _summaryRef(uid, today).get();
    if (summaryDoc.exists) {
      batch.update(_summaryRef(uid, today), {
        'totalWaterMl': FieldValue.increment(amountMl),
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
        totalWaterMl: amountMl,
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
