import 'package:get/get.dart';
import 'package:healthify/models/progress_model.dart';
import 'package:healthify/services/progress_service.dart';

class ProgressController extends GetxController {
  final ProgressService _service = ProgressService();

  bool isLoading = true;
  String selectedPeriod = 'Week'; // 'Week', 'Month', 'Year'
  final List<String> periods = ['Week', 'Month', 'Year'];

  ProgressData? data;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void setPeriod(String period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    update();

    try {
      data = await _service.fetchProgressData(selectedPeriod);
    } catch (e) {
      data = null;
    } finally {
      isLoading = false;
      update();
    }
  }
}
