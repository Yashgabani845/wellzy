import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/sleep_log_model.dart';
import 'package:healthify/core/utils/current_user.dart';

class SleepService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DocumentReference _sleepLogsRef(String uid) =>
      _db.collection('users').doc(uid).collection('sleep_logs').doc();

  DocumentReference _summaryRef(String uid, String date) =>
      _db.collection('users').doc(uid).collection('daily_summary').doc(date);

  Future<void> logSleep({
    required DateTime bedTime,
    required DateTime wakeTime,
    required int durationMinutes,
    required String quality,
  }) async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    final today = _getTodayDateString();
    final batch = _db.batch();

    // 1. Create sleep log entry
    final newLogRef = _sleepLogsRef(uid);
    final sleepLog = SleepLogEntry(
      id: newLogRef.id,
      userId: uid,
      bedTime: bedTime,
      wakeTime: wakeTime,
      durationMinutes: durationMinutes,
      quality: quality,
      date: today,
    );

    batch.set(newLogRef, sleepLog.toFirestoreMap());

    // 2. Update daily summary
    final summaryRef = _summaryRef(uid, today);
    batch.set(
      summaryRef,
      {
        'date': today,
        'userId': uid,
        'totalSleepMinutes': FieldValue.increment(durationMinutes),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
