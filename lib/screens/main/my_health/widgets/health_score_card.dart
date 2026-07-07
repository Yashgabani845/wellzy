import 'package:flutter/material.dart';
import 'package:healthify/models/my_health_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class HealthScoreCard extends StatelessWidget {
  final MyHealthData data;

  const HealthScoreCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = data.healthScoreWeeklyDiff >= 0;
    final color = data.healthScore >= 80
        ? AppColors.primary
        : data.healthScore >= 60
            ? Colors.orange
            : Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Health Score', style: AppTextStyles.subSectionHeading),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.primaryLight : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 14,
                      color: isPositive ? AppColors.primaryDark : Colors.red.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? "+" : ""}${data.healthScoreWeeklyDiff} This Week',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? AppColors.primaryDark : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: data.healthScore / 100.0,
                      strokeWidth: 9,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.healthScore}',
                        style: AppTextStyles.largeHeading.copyWith(fontSize: 26, color: AppColors.textPrimary),
                      ),
                      Text(
                        '/ 100',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.healthScoreGrade,
                      style: AppTextStyles.largeHeading.copyWith(fontSize: 22, color: color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your score is based on diet consistency, water intake, weight progress, sleep logs and daily exercise patterns over the last 7 days.',
                      style: AppTextStyles.captionSecondary.copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
