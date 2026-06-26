import 'package:healthify/models/dashboard_model.dart';

class WaterService {
  // Simulating an API or local database fetch
  Future<WaterData> fetchWaterData() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Network delay simulation
    return WaterData(
      total: 3.0, // 3 Liters = 3000 ml
      consumed: 1.2, // 1200 ml starting mock
    );
  }

  // Simulating an API update
  Future<bool> updateWaterIntake(double newConsumedLiters) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Save to backend/local DB here
    return true; 
  }
}
