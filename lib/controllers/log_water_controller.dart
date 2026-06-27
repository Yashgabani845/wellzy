import 'package:get/get.dart';
import 'package:healthify/services/water_service.dart';
import 'package:healthify/core/utils/refresh_data.dart';

class LogWaterController extends GetxController {
  final WaterService _waterService = WaterService();

  // State variables
  bool isLoading = true;
  int currentIntakeMl = 0; // Stored as ML for the UI
  int dailyGoalMl = 3000;  // 3 Liters

  @override
  void onInit() {
    super.onInit();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    isLoading = true;
    update();

    try {
      final summary = await _waterService.fetchWaterSummary();
      currentIntakeMl = ((summary['consumed'] ?? 0.0) * 1000).toInt();
      dailyGoalMl = ((summary['total'] ?? 2.5) * 1000).toInt();
    } catch (e) {
      // Fallback in case of error
      currentIntakeMl = 0;
      dailyGoalMl = 2500;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> addWater(int amountMl) async {
    currentIntakeMl += amountMl;
    
    // Cap visual
    if (currentIntakeMl > (dailyGoalMl * 1.5).toInt()) {
      currentIntakeMl = (dailyGoalMl * 1.5).toInt();
    }
    
    update();

    // Persist to service atomically
    await _waterService.logWater(amountMl);
    
    // Refresh summary
    await _loadWaterData();
    RefreshData.refreshAll();
  }

  double get progress {
    if (dailyGoalMl == 0) return 0.0;
    double p = currentIntakeMl / dailyGoalMl;
    return p > 1.0 ? 1.0 : p;
  }
}
