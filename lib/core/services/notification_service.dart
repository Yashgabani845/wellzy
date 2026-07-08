import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:healthify/routing/routes.dart';
import 'package:healthify/routing/router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the Local Notification service and configure Timezones
  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Initialize Timezones
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to Indian Standard Time if timezone fetch fails
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }

    // 2. Configure Android Initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Configure iOS Initialization
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 4. Initialize Local Notifications Plugin
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Request Notification Permissions for Android 13+ and iOS
  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    final bool? androidGranted = await androidImplementation?.requestNotificationsPermission();

    final bool? iosGranted = await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint("Notification tapped with payload: $payload");
    if (payload != null && payload.isNotEmpty) {
      try {
        appRouter.push(payload);
      } catch (e) {
        debugPrint("Failed to navigate to payload path: $e");
      }
    }
  }

  /// Helper to get tz.TZDateTime for a specific TimeOfDay today or tomorrow
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedule a daily recurring notification
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await init();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'wellzy_reminders_channel',
      'Reminders',
      channelDescription: 'Standard reminders for meal logging, sleep tracking, water intake, and weight entries.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint("Exact alarm scheduling failed, falling back to inexact mode: $e");
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    }
  }

  /// Cancel a single notification by ID
  Future<void> cancel(int id) async {
    await init();
    await _localNotifications.cancel(id);
  }

  /// Cancel a range of notification IDs (useful for water intervals)
  Future<void> cancelRange(int startId, int endId) async {
    await init();
    for (int id = startId; id <= endId; id++) {
      await _localNotifications.cancel(id);
    }
  }

  /// Schedule dynamic daytime interval water notifications (e.g. 8 AM to 10 PM)
  Future<void> scheduleWaterIntervals({
    required int intervalMinutes,
    required int startHour,
    required int endHour,
  }) async {
    await init();
    
    // First, cancel any existing water notifications in range 100-150
    await cancelRange(100, 150);

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int notificationId = 100;

    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        // Stop if we exceed the endHour
        if (hour == endHour && minute > 0) break;

        // Schedule daily alarm at this hour/minute
        tz.TZDateTime scheduledDate =
            tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
        
        // If scheduled date is in the past for today, schedule it starting tomorrow
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'wellzy_reminders_channel',
          'Reminders',
          channelDescription: 'Daytime interval reminders to log water intake.',
          importance: Importance.max,
          priority: Priority.high,
        );

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(),
        );

        try {
          await _localNotifications.zonedSchedule(
            notificationId,
            'Time to hydrate! 💧',
            'You are still below your water goal for today. Take a quick sip and log it now!',
            scheduledDate,
            platformDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: AppRoutes.logWater,
          );
        } catch (e) {
          debugPrint("Water exact alarm scheduling failed, falling back to inexact mode: $e");
          await _localNotifications.zonedSchedule(
            notificationId,
            'Time to hydrate! 💧',
            'You are still below your water goal for today. Take a quick sip and log it now!',
            scheduledDate,
            platformDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: AppRoutes.logWater,
          );
        }

        notificationId++;
        if (notificationId > 150) break; // Avoid exceeding ID range
      }
    }
  }

  /// Sync scheduled notifications based on today's logged state
  Future<void> syncDailyReminders({
    required bool waterGoalMet,
    required bool breakfastLogged,
    required bool lunchLogged,
    required bool dinnerLogged,
    required bool weightLogged,
    required bool sleepLogged,
  }) async {
    await init();
    final prefs = await SharedPreferences.getInstance();

    // Check if reminders are enabled in settings (default: true)
    final bool remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
    if (!remindersEnabled) {
      // Cancel all reminders
      await _localNotifications.cancelAll();
      return;
    }

    // 1. Water Reminder (Intervals)
    final bool waterEnabled = prefs.getBool('water_reminders_enabled') ?? true;
    if (waterEnabled && !waterGoalMet) {
      final int intervalMinutes = prefs.getInt('water_reminder_interval') ?? 120; // default 2 hours
      await scheduleWaterIntervals(
        intervalMinutes: intervalMinutes,
        startHour: 8,
        endHour: 22,
      );
    } else {
      await cancelRange(100, 150);
    }

    // Helper to extract TimeOfDay from local cache
    TimeOfDay getTime(String prefix, TimeOfDay defaultTime) {
      final int hour = prefs.getInt('${prefix}_hour') ?? defaultTime.hour;
      final int min = prefs.getInt('${prefix}_minute') ?? defaultTime.minute;
      return TimeOfDay(hour: hour, minute: min);
    }

    // 2. Breakfast Log Reminder
    final bool breakfastEnabled = prefs.getBool('breakfast_reminders_enabled') ?? true;
    if (breakfastEnabled && !breakfastLogged) {
      final t = getTime('breakfast', const TimeOfDay(hour: 8, minute: 30));
      await scheduleDaily(
        id: 30,
        title: 'Start your day right! 🍳',
        body: 'It\'s breakfast time. Log your morning meal to keep your calorie target on track.',
        hour: t.hour,
        minute: t.minute,
        payload: '${AppRoutes.addFood}?mealType=breakfast',
      );
    } else {
      await cancel(30);
    }

    // 3. Lunch Log Reminder
    final bool lunchEnabled = prefs.getBool('lunch_reminders_enabled') ?? true;
    if (lunchEnabled && !lunchLogged) {
      final t = getTime('lunch', const TimeOfDay(hour: 13, minute: 30));
      await scheduleDaily(
        id: 40,
        title: 'Time for Lunch! 🥗',
        body: 'Fuel your afternoon. Take a break and log your lunch details.',
        hour: t.hour,
        minute: t.minute,
        payload: '${AppRoutes.addFood}?mealType=lunch',
      );
    } else {
      await cancel(40);
    }

    // 4. Dinner Log Reminder
    final bool dinnerEnabled = prefs.getBool('dinner_reminders_enabled') ?? true;
    if (dinnerEnabled && !dinnerLogged) {
      final t = getTime('dinner', const TimeOfDay(hour: 20, minute: 0));
      await scheduleDaily(
        id: 50,
        title: 'Wrap up your day! 🍽️',
        body: 'Dinner is served! Log your final major meal of the day to evaluate your metrics.',
        hour: t.hour,
        minute: t.minute,
        payload: '${AppRoutes.addFood}?mealType=dinner',
      );
    } else {
      await cancel(50);
    }

    // 5. Weight Log Reminder
    final bool weightEnabled = prefs.getBool('weight_reminders_enabled') ?? true;
    if (weightEnabled && !weightLogged) {
      final t = getTime('weight', const TimeOfDay(hour: 9, minute: 0));
      await scheduleDaily(
        id: 20,
        title: 'Track your progress! ⚖️',
        body: 'Morning is the best time for consistent readings. Step on the scale and update your weight today!',
        hour: t.hour,
        minute: t.minute,
        payload: AppRoutes.updateWeight,
      );
    } else {
      await cancel(20);
    }

    // 6. Sleep Log Reminder
    final bool sleepEnabled = prefs.getBool('sleep_reminders_enabled') ?? true;
    if (sleepEnabled && !sleepLogged) {
      final t = getTime('sleep', const TimeOfDay(hour: 7, minute: 30));
      await scheduleDaily(
        id: 10,
        title: 'How did you sleep last night? 😴',
        body: 'Log your sleep duration to analyze your nightly recovery and consistency.',
        hour: t.hour,
        minute: t.minute,
        payload: AppRoutes.addSleep,
      );
    } else {
      await cancel(10);
    }
  }
}
