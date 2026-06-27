import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:healthify/core/repositories/auth_repository.dart';
import 'package:healthify/controllers/dashboard_controller.dart';
import 'package:healthify/controllers/profile_controller.dart';
import 'package:healthify/controllers/food_controller.dart';
import 'package:healthify/controllers/exercise_controller.dart';
import 'package:healthify/controllers/log_water_controller.dart';
import 'package:healthify/controllers/sleep_controller.dart';
import 'package:healthify/controllers/weight_controller.dart';
import 'package:healthify/controllers/progress_controller.dart';
class AuthController extends GetxController {
  final AuthRepository _authRepository;

  final Rx<fb.User?> _currentUser = Rx<fb.User?>(null);
  fb.User? get currentUser => _currentUser.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _onboardingCompleted = false.obs;
  bool get onboardingCompleted => _onboardingCompleted.value;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  @override
  void onInit() {
    super.onInit();
    // Restores session silently on controller creation
    restoreSession();
  }

  Future<void> restoreSession() async {
    _isLoading.value = true;
    try {
      final user = await _authRepository.restoreSession();
      if (user != null) {
        _currentUser.value = user;
        _onboardingCompleted.value = await _authRepository.isOnboardingCompleted(user.uid);
      }
    } catch (e) {
      // Fail silently for background session restoration
      _currentUser.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> login({required String email, required String password}) async {
    _isLoading.value = true;
    try {
      final user = await _authRepository.login(email: email, password: password);
      if (user != null) {
        _currentUser.value = user;
        _onboardingCompleted.value = await _authRepository.isOnboardingCompleted(user.uid);
        return null; // success
      }
      return "Login failed. Please try again.";
    } on fb.FirebaseAuthException catch (e) {
      debugPrint("AuthController Error (login): ${e.code} - ${e.message}");
      return _mapAuthError(e);
    } catch (e) {
      debugPrint("AuthController Error (login unexpected): $e");
      return "An unexpected error occurred: ${e.toString()}";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> signup({required String email, required String password, required String name}) async {
    _isLoading.value = true;
    try {
      final user = await _authRepository.signup(email: email, password: password, name: name);
      if (user != null) {
        _currentUser.value = user;
        _onboardingCompleted.value = false; // new signup starts with incomplete onboarding
        return null; // success
      }
      return "Registration failed. Please try again.";
    } on fb.FirebaseAuthException catch (e) {
      debugPrint("AuthController Error (signup): ${e.code} - ${e.message}");
      return _mapAuthError(e);
    } catch (e) {
      debugPrint("AuthController Error (signup unexpected): $e");
      return "An unexpected error occurred: ${e.toString()}";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> signInWithGoogle() async {
    _isLoading.value = true;
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        _currentUser.value = user;
        _onboardingCompleted.value = await _authRepository.isOnboardingCompleted(user.uid);
        return null; // success
      }
      return "Google Sign-In was cancelled or failed.";
    } on fb.FirebaseAuthException catch (e) {
      debugPrint("AuthController Error (google signin): ${e.code} - ${e.message}");
      return _mapAuthError(e);
    } on PlatformException catch (e) {
      debugPrint("AuthController Error (google signin platform): ${e.code} - ${e.message}");
      if (e.code == 'sign_in_failed') {
        return "Google Sign-In failed. Please check your network connection and try again.";
      }
      if (e.code == 'network_error') {
        return "Network error during Google Sign-In. Please check your connection.";
      }
      return e.message ?? "Google Sign-In failed on this device.";
    } catch (e) {
      debugPrint("AuthController Error (google signin unexpected): $e");
      return "An unexpected error occurred: ${e.toString()}";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    _isLoading.value = true;
    try {
      await _authRepository.logout();
      _currentUser.value = null;
      _onboardingCompleted.value = false;
      
      // Clear all user data controllers from memory
      Get.delete<DashboardController>(force: true);
      Get.delete<ProfileController>(force: true);
      Get.delete<FoodController>(force: true);
      Get.delete<ExerciseController>(force: true);
      Get.delete<LogWaterController>(force: true);
      Get.delete<SleepController>(force: true);
      Get.delete<WeightController>(force: true);
      Get.delete<ProgressController>(force: true);
    } catch (_) {
      // Ignored during sign-out
    } finally {
      _isLoading.value = false;
    }
  }

  String _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email address is already in use.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'invalid-email':
        return "The email address is invalid.";
      case 'weak-password':
        return "The password is too weak. Must be at least 8 characters.";
      case 'network-request-failed':
        return "No internet connection. Please check your network.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'too-many-requests':
        return "Too many requests. Please try again later.";
      default:
        return e.message ?? "Authentication failed.";
    }
  }
}
