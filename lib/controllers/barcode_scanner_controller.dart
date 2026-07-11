import 'dart:async';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:healthify/models/food_model.dart';
import 'package:healthify/services/food_service.dart';
import 'package:healthify/core/utils/refresh_data.dart';

class BarcodeScannerController extends GetxController {
  final FoodService _service = FoodService();

  bool isPermissionGranted = false;
  bool isFetching = false;
  bool isLogging = false;
  String? errorText;

  FoodItem? scannedFood;
  String barcodeInput = '';
  bool isCameraActive = true;

  // Logging parameters
  String selectedMealType = 'breakfast';
  double servingGrams = 100;
  int servings = 1;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  /// Check current camera permission status.
  Future<void> checkPermission() async {
    final status = await Permission.camera.status;
    isPermissionGranted = status.isGranted;
    update();
  }

  /// Request camera permission from the user.
  Future<void> requestPermission() async {
    final status = await Permission.camera.request();
    isPermissionGranted = status.isGranted;
    if (!isPermissionGranted) {
      if (status.isPermanentlyDenied) {
        errorText = 'Camera permission permanently denied. Please enable it in system settings.';
      } else {
        errorText = 'Camera permission is required to scan barcodes.';
      }
    } else {
      errorText = null;
    }
    update();
  }

  /// Fetch product from backend by barcode.
  Future<void> fetchProduct(String barcode) async {
    if (barcode.trim().isEmpty) return;

    isFetching = true;
    errorText = null;
    scannedFood = null;
    update();

    try {
      final food = await _service.fetchFoodByBarcode(barcode.trim());
      if (food != null) {
        scannedFood = food;
        servingGrams = food.defaultServingGrams;
        servings = 1;
        isCameraActive = false; // Turn off camera preview once product is loaded
      } else {
        errorText = 'Product not found. Try scanning another product or enter manual barcode.';
      }
    } on TimeoutException catch (e) {
      errorText = 'Connection timeout. Ensure your server at ${_service.baseUrl} is active and reachable.';
      print('[BarcodeScannerController] fetchProduct timeout: $e');
    } catch (e) {
      errorText = 'Connection failed. Check if server is running at ${_service.baseUrl} and reachable on your Wi-Fi network.';
      print('[BarcodeScannerController] fetchProduct error: $e');
    } finally {
      isFetching = false;
      update();
    }
  }

  /// Search barcode entered manually by user.
  Future<void> manualSearch() async {
    await fetchProduct(barcodeInput);
  }

  /// Updates the meal type selection.
  void setMealType(String mealType) {
    selectedMealType = mealType;
    update();
  }

  /// Updates serving weight in grams.
  void setServingGrams(double grams) {
    servingGrams = grams;
    update();
  }

  /// Updates quantity of servings.
  void setServings(int count) {
    if (count >= 1) {
      servings = count;
      update();
    }
  }

  /// Resets the controller state to allow scanning again.
  void resetScanner() {
    scannedFood = null;
    errorText = null;
    barcodeInput = '';
    isCameraActive = true;
    update();
  }

  // Macro calculation getters
  double get totalGrams => servingGrams * servings;
  double get totalCalories => scannedFood?.caloriesFor(totalGrams) ?? 0;
  double get totalProtein => scannedFood?.proteinFor(totalGrams) ?? 0;
  double get totalCarbs => scannedFood?.carbsFor(totalGrams) ?? 0;
  double get totalFat => scannedFood?.fatFor(totalGrams) ?? 0;
  double get totalFiber => ((scannedFood?.fiberPer100g ?? 0) / 100) * totalGrams;

  /// Log the scanned food item to the database.
  Future<bool> logFood() async {
    if (scannedFood == null) return false;

    isLogging = true;
    update();

    try {
      final entry = FoodLogEntry(
        food: scannedFood!,
        servingGrams: servingGrams,
        servings: servings,
        mealType: selectedMealType,
        date: DateTime.now(),
      );

      final success = await _service.logFood(entry);
      if (success) {
        RefreshData.refreshAll();
        resetScanner();
        return true;
      }
      return false;
    } catch (e) {
      print('[BarcodeScannerController] logFood error: $e');
      return false;
    } finally {
      isLogging = false;
      update();
    }
  }
}
