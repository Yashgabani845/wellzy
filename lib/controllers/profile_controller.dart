import 'package:get/get.dart';
import 'package:healthify/models/profile_model.dart';
import 'package:healthify/services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();

  bool isLoading = true;

  UserProfile? profile;
  UserStats? stats;

  // Mock settings state
  bool isDarkMode = false;
  bool useMetric = true;
  bool waterReminders = true;
  bool workoutReminders = false;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    update();

    try {
      final results = await Future.wait([
        _service.fetchUserProfile(),
        _service.fetchUserStats(),
      ]);
      profile = results[0] as UserProfile;
      stats = results[1] as UserStats;
    } catch (e) {
      profile = null;
      stats = null;
    } finally {
      isLoading = false;
      update();
    }
  }

  void toggleTheme(bool value) {
    isDarkMode = value;
    // In a real app, this would also trigger Get.changeThemeMode
    update();
  }

  void toggleUnits(bool metric) {
    useMetric = metric;
    update();
  }

  void toggleWaterReminders(bool value) {
    waterReminders = value;
    update();
  }

  void toggleWorkoutReminders(bool value) {
    workoutReminders = value;
    update();
  }

  Future<void> logout() async {
    await _service.logout();
    // Navigate to login screen or handle auth state
  }
}
