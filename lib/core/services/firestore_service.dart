import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference for users
  CollectionReference get _usersRef => _db.collection('users');

  /// Creates initial set of documents for a user upon signup.
  /// Uses a WriteBatch to make sure they are written atomically and optimized.
  Future<void> createInitialUserDocuments({
    required String uid,
    required String email,
  }) async {
    try {
      final batch = _db.batch();

      // 0. users/{uid}
      final userDocRef = _usersRef.doc(uid);
      batch.set(userDocRef, {
        'uid': uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 1. users/{uid}/profile
      final profileRef = _usersRef.doc(uid).collection('profile').doc('info');
      batch.set(profileRef, {
        'uid': uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. users/{uid}/onboarding
      final onboardingRef = _usersRef.doc(uid).collection('onboarding').doc('onboarding');
      batch.set(onboardingRef, {
        'completed': false,
        'currentStep': 0,
        'goalQuestion': 'What is your goal?',
        'genderQuestion': 'Gender',
        'ageQuestion': 'Age',
        'heightQuestion': 'Height',
        'weightQuestion': 'Weight',
        'targetWeightQuestion': 'Target Weight',
        'activityLevelQuestion': 'Activity Level',
        'dietPreferenceQuestion': 'Diet Preference',
      });

      // 3. users/{uid}/goals
      final goalsRef = _usersRef.doc(uid).collection('goals').doc('info');
      batch.set(goalsRef, <String, dynamic>{});

      // 4. users/{uid}/settings
      final settingsRef = _usersRef.doc(uid).collection('settings').doc('info');
      batch.set(settingsRef, {
        'notifications': true,
        'darkMode': false,
      });

      await batch.commit();
      debugPrint("Firestore: Initial user documents created successfully.");
    } catch (e) {
      debugPrint("Firestore Error: Failed to create initial user documents: $e");
      rethrow;
    }
  }

  /// Fetches only the onboarding completed status.
  /// We read users/{uid}/onboarding/onboarding
  Future<DocumentSnapshot<Map<String, dynamic>>> getOnboardingDoc(String uid) async {
    try {
      return await _usersRef
          .doc(uid)
          .collection('onboarding')
          .doc('onboarding')
          .get();
    } catch (e) {
      debugPrint("Firestore Error: Failed to fetch onboarding doc: $e");
      rethrow;
    }
  }

  /// Performs a merge update on the onboarding document.
  Future<void> updateOnboardingDoc({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _usersRef
          .doc(uid)
          .collection('onboarding')
          .doc('onboarding')
          .set(data, SetOptions(merge: true));
      debugPrint("Firestore: Onboarding doc updated successfully.");
    } catch (e) {
      debugPrint("Firestore Error: Failed to update onboarding doc: $e");
      rethrow;
    }
  }

  /// Performs a merge update on the goals document.
  Future<void> updateGoalsDoc({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _usersRef
          .doc(uid)
          .collection('goals')
          .doc('info')
          .set(data, SetOptions(merge: true));
      debugPrint("Firestore: Goals doc updated successfully.");
    } catch (e) {
      debugPrint("Firestore Error: Failed to update goals doc: $e");
      rethrow;
    }
  }
}
