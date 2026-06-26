import 'package:healthify/models/dashboard_model.dart';

class DashboardService {
  /// Fetches the mock data for the dashboard.
  /// Simulates a network delay.
  Future<DashboardModel> fetchDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API call

    return DashboardModel(
      userName: 'Yash',
      userAvatar: 'assets/images/avatar_male.png',
      caloriesTarget: 2190,
      caloriesConsumed: 340,
      protein: MacroData(total: 100, consumed: 35), // 65g left
      carbs: MacroData(total: 200, consumed: 80),   // 120g left
      fat: MacroData(total: 60, consumed: 28),      // 32g left
      water: WaterData(total: 2.5, consumed: 1.2),
      weight: WeightData(
        current: 74.2,
        last5Days: [75.0, 74.8, 74.5, 74.6, 74.2], // Values for the bar chart
      ),
      meals: [
        Meal(
          id: 'm1',
          name: 'Breakfast',
          description: 'Oatmeal & Berries',
          calories: 340,
          protein: 35,
          carbs: 80,
          fat: 28,
          imagePath: 'assets/images/meal_breakfast.png',
          isCompleted: true,
        ),
        Meal(
          id: 'm2',
          name: 'Lunch',
          description: 'Recommend 600 kcal',
          calories: 600,
          isCompleted: false,
        ),
        Meal(
          id: 'm3',
          name: 'Dinner',
          description: 'Recommend 500 kcal',
          calories: 500,
          isCompleted: false,
        ),
      ],
    );
  }
}
