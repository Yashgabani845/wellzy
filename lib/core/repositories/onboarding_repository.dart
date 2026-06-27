import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthify/core/services/firestore_service.dart';
import 'package:healthify/core/services/secure_storage_service.dart';

abstract class OnboardingRepository {
  Future<void> saveOnboardingStep({
    required String uid,
    required int step,
    required Map<String, dynamic> stepData,
  });

  Future<void> completeOnboarding({
    required String uid,
    required Map<String, dynamic> finalData,
  });
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final FirestoreService _firestoreService;
  final SecureStorageService _storageService;

  OnboardingRepositoryImpl({
    FirestoreService? firestoreService,
    SecureStorageService? storageService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? SecureStorageService();

  @override
  Future<void> saveOnboardingStep({
    required String uid,
    required int step,
    required Map<String, dynamic> stepData,
  }) async {
    final mergedData = Map<String, dynamic>.from(stepData);
    mergedData['currentStep'] = step;
    mergedData['completed'] = false;

    await _firestoreService.updateOnboardingDoc(
      uid: uid,
      data: mergedData,
    );
  }

  @override
  Future<void> completeOnboarding({
    required String uid,
    required Map<String, dynamic> finalData,
  }) async {
    final mergedData = Map<String, dynamic>.from(finalData);
    mergedData['completed'] = true;

    // 1. Save onboarding data to Firestore
    await _firestoreService.updateOnboardingDoc(
      uid: uid,
      data: mergedData,
    );

    // 2. Cache onboarding status locally to prevent Firestore read on launch
    await _storageService.setOnboardingCompleted(true);

    // Update FirebaseAuth displayName if provided
    final String name = mergedData['name'] ?? '';
    if (name.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
        await _storageService.saveName(name);
      } catch (e) {
        // Ignore failure
      }
    }

    // 2. Calculate daily goals based on onboarding answers
    final String goal = mergedData['goal'] ?? 'Lose Weight';
    final String gender = mergedData['gender'] ?? 'Male';
    final int age = mergedData['age'] ?? 25;
    final double height = (mergedData['height'] as num?)?.toDouble() ?? 175.0;
    final double weight = (mergedData['weight'] as num?)?.toDouble() ?? 70.0;
    final double targetWeight = (mergedData['targetWeight'] as num?)?.toDouble() ?? 68.0;
    final String activityLevel = mergedData['activityLevel'] ?? 'Moderately Active';

    // Base BMR (Mifflin-St Jeor Equation)
    double bmr = 0;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // TDEE multiplier
    double multiplier = 1.375;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'lightly active':
        multiplier = 1.375;
        break;
      case 'moderately active':
        multiplier = 1.55;
        break;
      case 'very active':
        multiplier = 1.725;
        break;
    }
    double tdee = bmr * multiplier;

    // Target Calories based on Goal
    double targetCalories = tdee;
    if (goal.toLowerCase().contains('lose')) {
      targetCalories = tdee - 500;
    } else if (goal.toLowerCase().contains('gain') || goal.toLowerCase().contains('muscle')) {
      targetCalories = tdee + 400;
    }

    if (targetCalories < 1200) targetCalories = 1200; // safe minimum limit

    // Macros distribution
    double protein = 1.8 * weight; // 1.8g per kg
    double fat = 0.25 * targetCalories / 9; // 25% of target calories from fat
    double carbs = (targetCalories - (protein * 4 + fat * 9)) / 4;

    // Timeline calculation
    double timeline = 0;
    if (goal.toLowerCase().contains('lose') && weight > targetWeight) {
      timeline = (weight - targetWeight) / 0.5; // assumes 0.5 kg loss per week
    } else if ((goal.toLowerCase().contains('gain') || goal.toLowerCase().contains('muscle')) && targetWeight > weight) {
      timeline = (targetWeight - weight) / 0.25; // assumes 0.25 kg gain per week
    }

    final goalsData = {
      'dailyCaloriesGoal': targetCalories.round(),
      'dailyProteinGoal': protein.round(),
      'dailyCarbsGoal': carbs.round(),
      'dailyFatGoal': fat.round(),
      'estimatedTimelineWeeks': timeline.round(),
    };

    // 3. Save goals data
    await _firestoreService.updateGoalsDoc(
      uid: uid,
      data: goalsData,
    );

    // 4. Create initial weight log entry
    final DateTime now = DateTime.now();
    final String dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final double heightM = height / 100;
    final double bmi = weight / (heightM * heightM);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weight_logs')
        .add({
      'userId': uid,
      'weightKg': weight,
      'bmi': bmi,
      'loggedAt': FieldValue.serverTimestamp(),
      'date': dateStr,
    });
  }
}
