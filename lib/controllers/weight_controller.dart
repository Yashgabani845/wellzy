import 'package:get/get.dart';
import 'package:healthify/models/weight_entry_model.dart';
import 'package:healthify/services/weight_service.dart';
import 'package:healthify/core/utils/refresh_data.dart';

class WeightController extends GetxController {
  final WeightService _weightService = WeightService();

  bool isLoading = true;
  bool isSaving = false;

  // All data comes from service
  double currentWeight = 70.0;
  double goalWeight = 68.0;
  double heightCm = 170.0;
  List<WeightEntry> entries = [];

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    update();

    try {
      final history = await _weightService.fetchWeightHistory();
      currentWeight = history.currentWeight;
      goalWeight = history.goalWeight;
      heightCm = history.heightCm;
      entries = history.entries;
    } catch (e) {
      // Fallback defaults if service fails
      currentWeight = 70.0;
      goalWeight = 68.0;
      heightCm = 170.0;
      entries = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  void setWeight(double weight) {
    currentWeight = weight;
    update();
  }

  double get bmi {
    final heightM = heightCm / 100;
    if (heightM <= 0) return 0;
    return currentWeight / (heightM * heightM);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  double get bmiPosition {
    // Map BMI to 0.0-1.0 range for the gradient bar (BMI 15-40 range)
    return ((bmi - 15) / 25).clamp(0.0, 1.0);
  }

  double get weightDifference => currentWeight - goalWeight;

  Future<void> saveWeight() async {
    isSaving = true;
    update();

    try {
      await _weightService.saveWeight(currentWeight);
      RefreshData.refreshAll();
      // Add to local entries
      entries.add(WeightEntry(weightKg: currentWeight, date: DateTime.now()));
    } finally {
      isSaving = false;
      update();
    }
  }
}
