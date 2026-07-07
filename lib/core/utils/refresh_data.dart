import 'package:get/get.dart';
import 'package:healthify/controllers/dashboard_controller.dart';
import 'package:healthify/controllers/progress_controller.dart';
import 'package:healthify/controllers/my_health_controller.dart';

class RefreshData {
  static void refreshAll() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().fetchData();
    }
    if (Get.isRegistered<ProgressController>()) {
      Get.find<ProgressController>().fetchData();
    }
    if (Get.isRegistered<MyHealthController>()) {
      Get.find<MyHealthController>().fetchData();
    }
  }
}
