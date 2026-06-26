import 'package:healthify/models/weight_entry_model.dart';

class WeightService {
  // Mock: Replace this single method with a real API call later
  Future<WeightHistory> fetchWeightHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    return WeightHistory(
      currentWeight: 72.5,
      goalWeight: 68.0,
      heightCm: 170.0,
      entries: [
        WeightEntry(weightKg: 74.2, date: now.subtract(const Duration(days: 6))),
        WeightEntry(weightKg: 73.8, date: now.subtract(const Duration(days: 5))),
        WeightEntry(weightKg: 73.5, date: now.subtract(const Duration(days: 4))),
        WeightEntry(weightKg: 73.1, date: now.subtract(const Duration(days: 3))),
        WeightEntry(weightKg: 72.9, date: now.subtract(const Duration(days: 2))),
        WeightEntry(weightKg: 72.7, date: now.subtract(const Duration(days: 1))),
        WeightEntry(weightKg: 72.5, date: now),
      ],
    );
  }

  // Mock: Replace with real API call to save new weight
  Future<bool> saveWeight(double weightKg) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // POST to API here
    return true;
  }
}
