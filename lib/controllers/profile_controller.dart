import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/core/utils/current_user.dart';
import 'package:healthify/models/profile_model.dart';
import 'package:healthify/services/profile_service.dart';
import 'package:healthify/core/services/notification_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = true;

  UserProfile? profile;
  UserStats? stats;

  // Settings state
  bool isDarkMode = false;
  bool useMetric = true;

  // Reminder settings (stored locally and synced to Firebase)
  bool remindersEnabled = true;
  bool waterRemindersEnabled = true;
  int waterReminderInterval = 120; // 120 minutes (2 hours)
  
  bool breakfastRemindersEnabled = true;
  int breakfastHour = 8;
  int breakfastMinute = 30;

  bool lunchRemindersEnabled = true;
  int lunchHour = 13;
  int lunchMinute = 30;

  bool dinnerRemindersEnabled = true;
  int dinnerHour = 20;
  int dinnerMinute = 0;

  bool weightRemindersEnabled = true;
  int weightHour = 9;
  int weightMinute = 0;

  bool sleepRemindersEnabled = true;
  int sleepHour = 7;
  int sleepMinute = 30;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    update();

    try {
      final results = await Future.wait([
        _service.fetchUserProfile(),
        _service.fetchUserStats(),
        _loadNotificationSettings(),
      ]);
      profile = results[0] as UserProfile;
      stats = results[1] as UserStats;
    } catch (e) {
      profile = null;
      stats = null;
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Load settings from SharedPreferences
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
    waterRemindersEnabled = prefs.getBool('water_reminders_enabled') ?? true;
    waterReminderInterval = prefs.getInt('water_reminder_interval') ?? 120;

    breakfastRemindersEnabled = prefs.getBool('breakfast_reminders_enabled') ?? true;
    breakfastHour = prefs.getInt('breakfast_hour') ?? 8;
    breakfastMinute = prefs.getInt('breakfast_minute') ?? 30;

    lunchRemindersEnabled = prefs.getBool('lunch_reminders_enabled') ?? true;
    lunchHour = prefs.getInt('lunch_hour') ?? 13;
    lunchMinute = prefs.getInt('lunch_minute') ?? 30;

    dinnerRemindersEnabled = prefs.getBool('dinner_reminders_enabled') ?? true;
    dinnerHour = prefs.getInt('dinner_hour') ?? 20;
    dinnerMinute = prefs.getInt('dinner_minute') ?? 0;

    weightRemindersEnabled = prefs.getBool('weight_reminders_enabled') ?? true;
    weightHour = prefs.getInt('weight_hour') ?? 9;
    weightMinute = prefs.getInt('weight_minute') ?? 0;

    sleepRemindersEnabled = prefs.getBool('sleep_reminders_enabled') ?? true;
    sleepHour = prefs.getInt('sleep_hour') ?? 7;
    sleepMinute = prefs.getInt('sleep_minute') ?? 30;
  }

  /// Save settings to SharedPreferences and Firestore
  Future<void> saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save locally
    await prefs.setBool('reminders_enabled', remindersEnabled);
    await prefs.setBool('water_reminders_enabled', waterRemindersEnabled);
    await prefs.setInt('water_reminder_interval', waterReminderInterval);
    
    await prefs.setBool('breakfast_reminders_enabled', breakfastRemindersEnabled);
    await prefs.setInt('breakfast_hour', breakfastHour);
    await prefs.setInt('breakfast_minute', breakfastMinute);

    await prefs.setBool('lunch_reminders_enabled', lunchRemindersEnabled);
    await prefs.setInt('lunch_hour', lunchHour);
    await prefs.setInt('lunch_minute', lunchMinute);

    await prefs.setBool('dinner_reminders_enabled', dinnerRemindersEnabled);
    await prefs.setInt('dinner_hour', dinnerHour);
    await prefs.setInt('dinner_minute', dinnerMinute);

    await prefs.setBool('weight_reminders_enabled', weightRemindersEnabled);
    await prefs.setInt('weight_hour', weightHour);
    await prefs.setInt('weight_minute', weightMinute);

    await prefs.setBool('sleep_reminders_enabled', sleepRemindersEnabled);
    await prefs.setInt('sleep_hour', sleepHour);
    await prefs.setInt('sleep_minute', sleepMinute);

    update();

    // Request system permissions for notifications when settings are updated
    await NotificationService().requestPermissions();

    // Trigger local reminder sync immediately
    await triggerReminderSync();

    // Save to Firestore in background
    final uid = await CurrentUser.getUid();
    if (uid != null) {
      try {
        await _db.collection('users').doc(uid).collection('settings').doc('info').set({
          'reminders_enabled': remindersEnabled,
          'water_reminders_enabled': waterRemindersEnabled,
          'water_reminder_interval': waterReminderInterval,
          'breakfast_reminders_enabled': breakfastRemindersEnabled,
          'breakfast_time': '${breakfastHour.toString().padLeft(2, '0')}:${breakfastMinute.toString().padLeft(2, '0')}',
          'lunch_reminders_enabled': lunchRemindersEnabled,
          'lunch_time': '${lunchHour.toString().padLeft(2, '0')}:${lunchMinute.toString().padLeft(2, '0')}',
          'dinner_reminders_enabled': dinnerRemindersEnabled,
          'dinner_time': '${dinnerHour.toString().padLeft(2, '0')}:${dinnerMinute.toString().padLeft(2, '0')}',
          'weight_reminders_enabled': weightRemindersEnabled,
          'weight_time': '${weightHour.toString().padLeft(2, '0')}:${weightMinute.toString().padLeft(2, '0')}',
          'sleep_reminders_enabled': sleepRemindersEnabled,
          'sleep_time': '${sleepHour.toString().padLeft(2, '0')}:${sleepMinute.toString().padLeft(2, '0')}',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Failed to sync reminder settings to Firestore: $e");
      }
    }
  }

  /// Trigger active sync of notifications based on current logs
  Future<void> triggerReminderSync() async {
    final uid = await CurrentUser.getUid();
    if (uid == null) return;

    final String today = _getTodayDateString();
    
    // Fetch today's summary to check completed goals
    bool waterGoalMet = false;
    bool weightLogged = false;
    bool sleepLogged = false;

    try {
      final summaryDoc = await _db.collection('users').doc(uid).collection('daily_summary').doc(today).get();
      if (summaryDoc.exists && summaryDoc.data() != null) {
        final data = summaryDoc.data()!;
        final int totalWater = (data['totalWaterMl'] ?? 0) as int;
        final int waterGoal = (data['waterGoalMl'] ?? 2500) as int;
        waterGoalMet = totalWater >= waterGoal;
        weightLogged = data['weightKg'] != null;
        sleepLogged = (data['totalSleepMinutes'] ?? 0) as int > 0;
      }
    } catch (_) {}

    // Check today's meal logs
    bool breakfastLogged = false;
    bool lunchLogged = false;
    bool dinnerLogged = false;

    try {
      final foodLogsSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('food_logs')
          .where('dateStr', isEqualTo: today)
          .get();

      for (final doc in foodLogsSnap.docs) {
        final mealType = (doc.data()['mealType']?.toString() ?? '').toLowerCase();
        if (mealType == 'breakfast') breakfastLogged = true;
        if (mealType == 'lunch') lunchLogged = true;
        if (mealType == 'dinner') dinnerLogged = true;
      }
    } catch (_) {}

    // Sync via NotificationService
    await NotificationService().syncDailyReminders(
      waterGoalMet: waterGoalMet,
      breakfastLogged: breakfastLogged,
      lunchLogged: lunchLogged,
      dinnerLogged: dinnerLogged,
      weightLogged: weightLogged,
      sleepLogged: sleepLogged,
    );
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void toggleTheme(bool value) {
    isDarkMode = value;
    update();
  }

  void toggleUnits(bool metric) {
    useMetric = metric;
    update();
  }

  Future<void> logout() async {
    await _service.logout();
  }
}
