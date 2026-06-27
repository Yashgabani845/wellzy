import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference _profileRef(String uid) =>
      _db.collection('users').doc(uid).collection('profile').doc('info');

  DocumentReference _onboardingRef(String uid) =>
      _db.collection('users').doc(uid).collection('onboarding').doc('onboarding');

  /// Fetches user profile info from Firestore.
  Future<UserProfile> fetchUserProfile() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    final profileDoc = await _profileRef(uid).get();
    final onboardingDoc = await _onboardingRef(uid).get();

    final String fallbackEmail = await CurrentUser.getEmail() ?? '';
    final String fallbackName = await CurrentUser.getName() ?? 'Wellzy User';
    
    String defaultAvatar = 'assets/images/avatar_male.png';
    if (onboardingDoc.exists && onboardingDoc.data() != null) {
      final oData = onboardingDoc.data() as Map<String, dynamic>;
      if (oData['gender']?.toString().toLowerCase() == 'female') {
        defaultAvatar = 'assets/images/avatar_female.png';
      }
    }

    if (profileDoc.exists && profileDoc.data() != null) {
      final data = profileDoc.data() as Map<String, dynamic>;
      final Timestamp? joinedTS = data['createdAt'] as Timestamp?;
      return UserProfile(
        id: uid,
        name: data['name'] ?? fallbackName,
        email: data['email'] ?? fallbackEmail,
        avatarUrl: data['avatarUrl'] ?? defaultAvatar,
        joinedDate: joinedTS?.toDate() ?? DateTime.now(),
        isPro: data['isPro'] ?? false,
      );
    }

    return UserProfile(
      id: uid,
      name: fallbackName,
      email: fallbackEmail,
      avatarUrl: defaultAvatar,
      joinedDate: DateTime.now(),
      isPro: false,
    );
  }

  /// Fetches user weight/streak statistics from Firestore.
  Future<UserStats> fetchUserStats() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) throw Exception("User not authenticated");

    final onboardingDoc = await _onboardingRef(uid).get();
    final profileDoc = await _profileRef(uid).get();

    double currentWeight = 70.0;
    double goalWeight = 68.0;

    // Check onboarding answers for initial values
    if (onboardingDoc.exists && onboardingDoc.data() != null) {
      final oData = onboardingDoc.data() as Map<String, dynamic>?;
      currentWeight = (oData?['weight'] as num?)?.toDouble() ?? 70.0;
      goalWeight = (oData?['targetWeight'] as num?)?.toDouble() ?? 68.0;
    }

    // Check profile info for latest updated weight
    if (profileDoc.exists && profileDoc.data() != null) {
      final pData = profileDoc.data() as Map<String, dynamic>?;
      if (pData?['currentWeight'] != null) {
        currentWeight = (pData?['currentWeight'] as num).toDouble();
      }
    }

    // Calculate Total Workouts
    int totalWorkouts = 0;
    try {
      final exerciseSnap = await _db.collection('users').doc(uid).collection('exercise_logs').count().get();
      totalWorkouts = exerciseSnap.count ?? 0;
    } catch (_) {}

    // Calculate Streak Days (simple count of daily_summary docs)
    int streakDays = 0;
    try {
      final summarySnap = await _db.collection('users').doc(uid).collection('daily_summary').count().get();
      streakDays = summarySnap.count ?? 0;
    } catch (_) {}

    return UserStats(
      currentWeight: currentWeight,
      goalWeight: goalWeight,
      streakDays: streakDays,
      totalWorkouts: totalWorkouts,
    );
  }

  Future<void> logout() async {
    // Session logout handled centrally inside AuthController
  }
}
