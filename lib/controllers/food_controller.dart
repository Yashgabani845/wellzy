import 'dart:async';
import 'package:get/get.dart';
import 'package:healthify/models/food_model.dart';
import 'package:healthify/services/food_service.dart';
import 'package:healthify/core/utils/refresh_data.dart';

class FoodController extends GetxController {
  final FoodService _service = FoodService();

  bool isLoading = true;
  bool isSearching = false;
  bool isLogging = false;

  // Filters
  bool isVegOnly = false;
  bool isJainOnly = false;

  // Data from service
  List<FoodItem> recommendations = [];
  List<FoodItem> searchResults = [];
  String searchQuery = '';

  // UI state
  String selectedMealType = 'breakfast';
  FoodItem? selectedFood;
  double servingGrams = 100;
  int servings = 1;

  // Debounce timer — waits 400ms after user stops typing before querying
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _loadRecommendations(isInitial: true);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void toggleVeg() {
    isVegOnly = !isVegOnly;
    if (!isVegOnly && isJainOnly) {
      isJainOnly = false;
    }
    update();
    _refreshData();
  }

  void toggleJain() {
    isJainOnly = !isJainOnly;
    if (isJainOnly) {
      isVegOnly = true;
    }
    update();
    _refreshData();
  }

  void _refreshData() {
    if (searchQuery.isNotEmpty) {
      _executeSearch(searchQuery);
    } else {
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations({bool isInitial = false}) async {
    if (isInitial) {
      isLoading = true;
    } else {
      isSearching = true;
    }
    update();

    try {
      recommendations = await _service.fetchRecommendations(
        isVeg: isVegOnly,
        isJain: isJainOnly,
        mealType: selectedMealType,
      );
    } catch (e) {
      print("Error loading recommendations: $e");
      recommendations = [];
    } finally {
      isLoading = false;
      isSearching = false;
      update();
    }
  }

  /// Called on every keystroke — debounces before hitting DB.
  void search(String query) {
    searchQuery = query;

    // Cancel any pending search
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      searchResults = [];
      isSearching = false;
      update();
      _loadRecommendations();
      return;
    }

    // Show searching indicator immediately for responsiveness
    isSearching = true;
    update();

    // Debounce: wait 400ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _executeSearch(query);
    });
  }

  /// Actually hits MongoDB — only called after debounce settles.
  Future<void> _executeSearch(String query) async {
    isSearching = true;
    update();

    try {
      searchResults = await _service.searchFood(
        query,
        isVeg: isVegOnly,
        isJain: isJainOnly,
      );
    } catch (e) {
      print("Error searching food: $e");
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
    _refreshData();
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
