import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/services/sleep_service.dart';
import 'package:healthify/core/utils/refresh_data.dart';

class SleepController extends GetxController {
  final SleepService _service = SleepService();

  bool isLogging = false;

  DateTime bedTime = DateTime.now().subtract(const Duration(hours: 8));
  DateTime wakeTime = DateTime.now();
  String selectedQuality = 'Good';

  final List<String> qualityOptions = ['Poor', 'Fair', 'Good', 'Excellent'];

  void setBedTime(DateTime time) {
    bedTime = time;
    update();
  }

  void setWakeTime(DateTime time) {
    wakeTime = time;
    update();
  }

  void setQuality(String quality) {
    selectedQuality = quality;
    update();
  }

  int get durationMinutes {
    int diff = wakeTime.difference(bedTime).inMinutes;
    if (diff < 0) {
      // If wake time is before bed time on the clock, assume wake time is next day
      diff += 24 * 60;
    }
    return diff;
  }

  String get durationFormatted {
    final mins = durationMinutes;
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  Future<void> logSleep() async {
    isLogging = true;
    update();

    try {
      await _service.logSleep(
        bedTime: bedTime,
        wakeTime: wakeTime,
        durationMinutes: durationMinutes,
        quality: selectedQuality.toLowerCase(),
      );
      RefreshData.refreshAll();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log sleep: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLogging = false;
      update();
    }
  }
}
