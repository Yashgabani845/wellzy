import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/profile_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  String _formatTime(int hour, int minute) {
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes Minutes';
    final double hours = minutes / 60.0;
    if (hours == 1.0) return '1 Hour';
    return '${hours.toStringAsFixed(hours == hours.toInt() ? 0 : 1)} Hours';
  }

  Future<void> _selectTime(
    BuildContext context,
    ProfileController controller,
    String prefix,
    int initialHour,
    int initialMinute,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (prefix == 'breakfast') {
        controller.breakfastHour = picked.hour;
        controller.breakfastMinute = picked.minute;
      } else if (prefix == 'lunch') {
        controller.lunchHour = picked.hour;
        controller.lunchMinute = picked.minute;
      } else if (prefix == 'dinner') {
        controller.dinnerHour = picked.hour;
        controller.dinnerMinute = picked.minute;
      } else if (prefix == 'weight') {
        controller.weightHour = picked.hour;
        controller.weightMinute = picked.minute;
      } else if (prefix == 'sleep') {
        controller.sleepHour = picked.hour;
        controller.sleepMinute = picked.minute;
      }
      await controller.saveNotificationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Reminder Schedule', style: AppTextStyles.sectionHeading),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master Switch
                  _buildSettingsGroup([
                    _buildSettingsToggle(
                      icon: Icons.notifications_active_outlined,
                      title: 'Enable Reminders',
                      subtitle: 'Allow app to send daily reminders',
                      value: controller.remindersEnabled,
                      onChanged: (val) async {
                        controller.remindersEnabled = val;
                        await controller.saveNotificationSettings();
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  if (controller.remindersEnabled) ...[
                    const Text('Trackers', style: AppTextStyles.subSectionHeading),
                    const SizedBox(height: 12),
                    
                    // Water Log configuration
                    _buildSettingsGroup([
                      _buildSettingsToggle(
                        icon: Icons.water_drop_outlined,
                        title: 'Water Intake Reminder',
                        subtitle: 'Remind during daytime active hours',
                        value: controller.waterRemindersEnabled,
                        onChanged: (val) async {
                          controller.waterRemindersEnabled = val;
                          await controller.saveNotificationSettings();
                        },
                      ),
                      if (controller.waterRemindersEnabled)
                        _buildIntervalSelector(
                          context: context,
                          title: 'Reminder Frequency',
                          currentValue: controller.waterReminderInterval,
                          onChanged: (val) async {
                            if (val != null) {
                              controller.waterReminderInterval = val;
                              await controller.saveNotificationSettings();
                            }
                          },
                        ),
                    ]),
                    const SizedBox(height: 24),

                    const Text('Meal Reminders', style: AppTextStyles.subSectionHeading),
                    const SizedBox(height: 12),

                    // Meals configurations
                    _buildSettingsGroup([
                      _buildSettingsToggle(
                        icon: Icons.breakfast_dining_outlined,
                        title: 'Breakfast Reminder',
                        value: controller.breakfastRemindersEnabled,
                        onChanged: (val) async {
                          controller.breakfastRemindersEnabled = val;
                          await controller.saveNotificationSettings();
                        },
                      ),
                      if (controller.breakfastRemindersEnabled)
                        _buildTimeRow(
                          context: context,
                          title: 'Breakfast Alert Time',
                          timeText: _formatTime(controller.breakfastHour, controller.breakfastMinute),
                          onTap: () => _selectTime(
                            context,
                            controller,
                            'breakfast',
                            controller.breakfastHour,
                            controller.breakfastMinute,
                          ),
                        ),
                      const Divider(height: 1, indent: 56, color: AppColors.border),
                      _buildSettingsToggle(
                        icon: Icons.lunch_dining_outlined,
                        title: 'Lunch Reminder',
                        value: controller.lunchRemindersEnabled,
                        onChanged: (val) async {
                          controller.lunchRemindersEnabled = val;
                          await controller.saveNotificationSettings();
                        },
                      ),
                      if (controller.lunchRemindersEnabled)
                        _buildTimeRow(
                          context: context,
                          title: 'Lunch Alert Time',
                          timeText: _formatTime(controller.lunchHour, controller.lunchMinute),
                          onTap: () => _selectTime(
                            context,
                            controller,
                            'lunch',
                            controller.lunchHour,
                            controller.lunchMinute,
                          ),
                        ),
                      const Divider(height: 1, indent: 56, color: AppColors.border),
                      _buildSettingsToggle(
                        icon: Icons.dinner_dining_outlined,
                        title: 'Dinner Reminder',
                        value: controller.dinnerRemindersEnabled,
                        onChanged: (val) async {
                          controller.dinnerRemindersEnabled = val;
                          await controller.saveNotificationSettings();
                        },
                      ),
                      if (controller.dinnerRemindersEnabled)
                        _buildTimeRow(
                          context: context,
                          title: 'Dinner Alert Time',
                          timeText: _formatTime(controller.dinnerHour, controller.dinnerMinute),
                          onTap: () => _selectTime(
                            context,
                            controller,
                            'dinner',
                            controller.dinnerHour,
                            controller.dinnerMinute,
                          ),
                        ),
                    ]),
                    const SizedBox(height: 24),

                    const Text('Body Metrics Reminders', style: AppTextStyles.subSectionHeading),
                    const SizedBox(height: 12),

                    // Sleep & Weight configurations
                    _buildSettingsGroup([
                      _buildSettingsToggle(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Weight Tracking Reminder',
                        value: controller.weightRemindersEnabled,
                        onChanged: (val) async {
                          controller.weightRemindersEnabled = val;
                          await controller.saveNotificationSettings();
                        },
                      ),
                      if (controller.weightRemindersEnabled)
                        _buildTimeRow(
                          context: context,
                          title: 'Weight Alert Time',
                          timeText: _formatTime(controller.weightHour, controller.weightMinute),
                          onTap: () => _selectTime(
                            context,
                            controller,
                            'weight',
                            controller.weightHour,
                            controller.weightMinute,
                          ),
                        ),
                      const Divider(height: 1, indent: 56, color: AppColors.border),
                      _buildSettingsToggle(
                        icon: Icons.bedtime_outlined,
                        title: 'Sleep Tracking Reminder',
                        value: controller.sleepRemindersEnabled,
                        onChanged: (val) async {
                          controller.sleepRemindersEnabled = val;
                          await controller.saveNotificationSettings();
                        },
                      ),
                      if (controller.sleepRemindersEnabled)
                        _buildTimeRow(
                          context: context,
                          title: 'Sleep Alert Time',
                          timeText: _formatTime(controller.sleepHour, controller.sleepMinute),
                          onTap: () => _selectTime(
                            context,
                            controller,
                            'sleep',
                            controller.sleepHour,
                            controller.sleepMinute,
                          ),
                        ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required BuildContext context,
    required String title,
    required String timeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 56, right: 16, top: 8, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Row(
              children: [
                Text(
                  timeText,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_right_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector({
    required BuildContext context,
    required String title,
    required int currentValue,
    required ValueChanged<int?> onChanged,
  }) {
    final intervals = [30, 60, 120, 180, 240];
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16, top: 4, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: currentValue,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              onChanged: onChanged,
              items: intervals.map((val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text(_formatInterval(val)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
