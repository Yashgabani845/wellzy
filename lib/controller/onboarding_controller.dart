import 'package:get/get.dart';
import 'package:healthify/core/repositories/onboarding_repository.dart';

class OnboardingController extends GetxController {
  final OnboardingRepository _onboardingRepository;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  OnboardingController({OnboardingRepository? onboardingRepository})
      : _onboardingRepository = onboardingRepository ?? OnboardingRepositoryImpl();

  /// Saves the progress of a specific onboarding step.
  Future<void> saveStep({
    required String uid,
    required int step,
    required Map<String, dynamic> stepData,
  }) async {
    _isLoading.value = true;
    try {
      await _onboardingRepository.saveOnboardingStep(
        uid: uid,
        step: step,
        stepData: stepData,
      );
    } catch (_) {
      // Bypassed for resilient background saves
    } finally {
      _isLoading.value = false;
    }
  }

  /// Completes the onboarding process, setting completed = true.
  Future<bool> completeOnboarding({
    required String uid,
    required Map<String, dynamic> finalData,
  }) async {
    _isLoading.value = true;
    try {
      await _onboardingRepository.completeOnboarding(
        uid: uid,
        finalData: finalData,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
