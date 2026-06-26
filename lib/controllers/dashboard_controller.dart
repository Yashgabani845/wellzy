import 'package:get/get.dart';
import 'package:healthify/models/dashboard_model.dart';
import 'package:healthify/services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();

  DashboardModel? dashboardData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading = true;
      errorMessage = null;
      update();

      dashboardData = await _service.fetchDashboardData();
    } catch (e) {
      errorMessage = "Failed to load dashboard data.";
    } finally {
      isLoading = false;
      update();
    }
  }
}
