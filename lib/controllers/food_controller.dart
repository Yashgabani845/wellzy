import 'package:get/get.dart';
import 'package:healthify/models/food_model.dart';
import 'package:healthify/services/food_service.dart';
import 'package:healthify/core/utils/refresh_data.dart';

class FoodController extends GetxController {
  final FoodService _service = FoodService();

  bool isLoading = true;
  bool isSearching = false;
  bool isLogging = false;

  // Data from service
  List<FoodItem> recommendations = [];
  List<FoodItem> searchResults = [];
  String searchQuery = '';

  // UI state
  String selectedMealType = 'breakfast';
  FoodItem? selectedFood;
  double servingGrams = 100;
  int servings = 1;

  @override
  void onInit() {
    super.onInit();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    isLoading = true;
    update();

    try {
      recommendations = await _service.fetchRecommendations();
    } catch (e) {
      recommendations = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> search(String query) async {
    searchQuery = query;
    if (query.isEmpty) {
      searchResults = [];
      isSearching = false;
      update();
      return;
    }

    isSearching = true;
    update();

    try {
      searchResults = await _service.searchFood(query);
    } catch (e) {
      searchResults = [];
    } finally {
      isSearching = false;
      update();
    }
  }

  void selectFood(FoodItem food) {
    selectedFood = food;
    servingGrams = food.defaultServingGrams;
    servings = 1;
    update();
  }

  void clearSelection() {
    selectedFood = null;
    update();
  }

  void setMealType(String type) {
    selectedMealType = type;
    update();
  }

  void setServingGrams(double grams) {
    servingGrams = grams;
    update();
  }

  void setServings(int count) {
    servings = count;
    update();
  }

  // Calculated values
  double get totalGrams => servingGrams * servings;
  double get totalCalories => selectedFood?.caloriesFor(totalGrams) ?? 0;
  double get totalProtein => selectedFood?.proteinFor(totalGrams) ?? 0;
  double get totalCarbs => selectedFood?.carbsFor(totalGrams) ?? 0;
  double get totalFat => selectedFood?.fatFor(totalGrams) ?? 0;

  bool get hasActiveSearch => searchQuery.isNotEmpty;

  Future<void> logFood() async {
    if (selectedFood == null) return;

    isLogging = true;
    update();

    try {
      final entry = FoodLogEntry(
        food: selectedFood!,
        servingGrams: servingGrams,
        servings: servings,
        mealType: selectedMealType,
        date: DateTime.now(),
      );
      await _service.logFood(entry);
      RefreshData.refreshAll();
      selectedFood = null;
      searchQuery = '';
      searchResults = [];
    } finally {
      isLogging = false;
      update();
    }
  }
}
