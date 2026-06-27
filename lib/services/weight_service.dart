import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/models/weight_log_model.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/weight_entry_model.dart';

class WeightService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _weightLogsRef(String uid) =>
      _db.collection('users').doc(uid).collection('weight_logs');

  DocumentReference _onboardingRef(String uid) =>
      _db.collection('users').doc(uid).collection('onboarding').doc('onboarding');

  DocumentReference _summaryRef(String uid, String date) =>
      _db.collection('users').doc(uid).collection('daily_summary').doc(date);

  DocumentReference _profileRef(String uid) =>
      _db.collection('users').doc(uid).collection('profile').doc('info');

  /// Fetches the real weight history from Firestore.
  Future<WeightHistory> fetchWeightHistory() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    // 1. Fetch onboarding info (for height & targetWeight)
    final onboardingDoc = await _onboardingRef(uid).get();
    double height = 175.0;
    double targetWeight = 68.0;

    if (onboardingDoc.exists && onboardingDoc.data() != null) {
      final data = onboardingDoc.data() as Map<String, dynamic>;
      height = (data['height'] as num?)?.toDouble() ?? 175.0;
      targetWeight = (data['targetWeight'] as num?)?.toDouble() ?? 68.0;
    }

    // 2. Fetch weight logs
    final logsSnap = await _weightLogsRef(uid)
        .orderBy('loggedAt', descending: false)
        .limit(30)
        .get();

    final List<WeightEntry> entries = [];
    double currentWeight = targetWeight; // fallback

    for (final doc in logsSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final wtLog = WeightLogEntry.fromMap(data, docId: doc.id);
      currentWeight = wtLog.weightKg;
      entries.add(WeightEntry(
        weightKg: wtLog.weightKg,
        date: wtLog.loggedAt,
        bmi: wtLog.bmi,
      ));
    }

    // If no weight entries exist yet, fallback to onboarding weight
    if (entries.isEmpty) {
      if (onboardingDoc.exists && onboardingDoc.data() != null) {
        final oData = onboardingDoc.data() as Map<String, dynamic>?;
        final initialWeight = (oData?['weight'] as num?)?.toDouble() ?? 70.0;
        currentWeight = initialWeight;
        entries.add(WeightEntry(
          weightKg: initialWeight,
          date: DateTime.now().subtract(const Duration(minutes: 5)),
          bmi: WeightLogEntry.calculateBmi(initialWeight, height),
        ));
      }
    }

    return WeightHistory(
      currentWeight: currentWeight,
      goalWeight: targetWeight,
      heightCm: height,
      entries: entries,
    );
  }

  /// Logs a new weight and updates the profile info + daily summary.
  Future<bool> saveWeight(double weightKg) async {
    final uid = await CurrentUser.getUid();
    if (uid == null) return false;

    final today = _getTodayDateString();
    
    // 1. Fetch height to calculate BMI
    final onboardingDoc = await _onboardingRef(uid).get();
    double height = 175.0;
    if (onboardingDoc.exists && onboardingDoc.data() != null) {
      final oData = onboardingDoc.data() as Map<String, dynamic>?;
      height = (oData?['height'] as num?)?.toDouble() ?? 175.0;
    }
    
    final bmi = WeightLogEntry.calculateBmi(weightKg, height);
    final batch = _db.batch();

    // 2. Add weight log entry
    final weightLogDoc = _weightLogsRef(uid).doc();
    final logEntry = WeightLogEntry(
      id: weightLogDoc.id,
      userId: uid,
      weightKg: weightKg,
      bmi: bmi,
      loggedAt: DateTime.now(),
      date: today,
    );
    batch.set(weightLogDoc, logEntry.toFirestoreMap());

    // 3. Update summary weight
    batch.set(_summaryRef(uid, today), {
      'weightKg': weightKg,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 4. Update weight in profile info
    batch.set(_profileRef(uid), {
      'currentWeight': weightKg,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
    return true;
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
