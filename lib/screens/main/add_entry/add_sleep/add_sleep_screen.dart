import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/sleep_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/common/loading_overlay.dart';
import 'package:intl/intl.dart';

class AddSleepScreen extends StatefulWidget {
  const AddSleepScreen({super.key});

  @override
  State<AddSleepScreen> createState() => _AddSleepScreenState();
}

class _AddSleepScreenState extends State<AddSleepScreen> {
  final SleepController _controller = Get.put(SleepController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Sleep', style: AppTextStyles.sectionHeading),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: GetBuilder<SleepController>(
        builder: (controller) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Header Card with Duration
                          _buildDurationHeader(controller),
                          const SizedBox(height: 24),
                          
                          // Time Pickers
                          _buildTimePickerRow(
                            context,
                            title: 'Bed Time',
                            icon: Icons.bedtime_outlined,
                            color: AppColors.primary,
                            time: controller.bedTime,
                            onTimeChanged: (t) => controller.setBedTime(t),
                          ),
                          const SizedBox(height: 16),
                          _buildTimePickerRow(
                            context,
                            title: 'Wake Time',
                            icon: Icons.wb_sunny_outlined,
                            color: const Color(0xFFFFA726),
                            time: controller.wakeTime,
                            onTimeChanged: (t) => controller.setWakeTime(t),
                          ),
                          const SizedBox(height: 32),
    
                          // Quality Selector
                          _buildQualitySelector(controller),
                        ],
                      ),
                    ),
                  ),
    
                  // Log Button
                  _buildLogButton(context, controller),
                ],
              ),
              if (controller.isLogging)
                const LoadingOverlay(message: 'Logging Sleep...'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDurationHeader(SleepController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.nights_stay, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sleep Duration',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.durationFormatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerRow(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required DateTime time,
    required ValueChanged<DateTime> onTimeChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(time),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showTimePicker(context, time, onTimeChanged),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Change', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, DateTime initialTime, ValueChanged<DateTime> onTimeChanged) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  // Keep current date, just update time
                  final updated = DateTime(
                    initialTime.year,
                    initialTime.month,
                    initialTime.day,
                    newDateTime.hour,
                    newDateTime.minute,
                  );
                  onTimeChanged(updated);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySelector(SleepController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sleep Quality', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          Row(
            children: controller.qualityOptions.map((q) {
              final isSelected = controller.selectedQuality == q;
              IconData iconData;
              Color activeColor;
              switch (q) {
                case 'Poor':
                  iconData = Icons.sentiment_very_dissatisfied;
                  activeColor = Colors.redAccent;
                  break;
                case 'Fair':
                  iconData = Icons.sentiment_neutral;
                  activeColor = Colors.orangeAccent;
                  break;
                case 'Good':
                  iconData = Icons.sentiment_satisfied;
                  activeColor = AppColors.primary;
                  break;
                case 'Excellent':
                  iconData = Icons.sentiment_very_satisfied;
                  activeColor = Colors.green;
                  break;
                default:
                  iconData = Icons.face;
                  activeColor = AppColors.primary;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setQuality(q),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? activeColor : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(iconData, color: isSelected ? activeColor : AppColors.textLight, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          q,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? activeColor : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton(BuildContext context, SleepController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLogging
              ? null
              : () async {
                  await controller.logSleep();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Sleep logged successfully! 🌙'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 20),
              SizedBox(width: 8),
              Text('Save Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
