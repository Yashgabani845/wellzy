import 'package:get/get.dart';
import 'package:healthify/models/my_health_model.dart';
import 'package:healthify/services/my_health_service.dart';

class MyHealthController extends GetxController {
  final MyHealthService _service = MyHealthService();

  MyHealthData? healthData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    fetchData(isInitial: true);
  }

  Future<void> fetchData({bool isInitial = false}) async {
    try {
      if (isInitial || healthData == null) {
        isLoading = true;
        errorMessage = null;
        update();
      }

      final data = await _service.fetchMyHealthData();
      healthData = data;
      errorMessage = null;
    } catch (e) {
      print("Error fetching health data: $e");
      errorMessage = "Failed to load health assessment.";
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateMedicalProfile(MedicalProfileModel profile) async {
    try {
      isLoading = true;
      update();
      await _service.saveMedicalProfile(profile);
      await fetchData(); // refresh data with new medical targets/profile
    } catch (e) {
      print("Error updating medical profile: $e");
      errorMessage = "Failed to save medical profile.";
    } finally {
      isLoading = false;
      update();
    }
  }
}
