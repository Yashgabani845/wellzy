import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_constants.dart';
import 'package:healthify/theme/app_text_styles.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppConstants.borderRadiusCard,
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Metric Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.largeHeading.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
