import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_constants.dart';
import 'package:healthify/theme/app_text_styles.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationNormal,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.card,
          borderRadius: AppConstants.borderRadiusCard,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppConstants.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            AnimatedContainer(
              duration: AppConstants.durationNormal,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subSectionHeading.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Circle
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: AnimatedContainer(
                duration: AppConstants.durationNormal,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 8,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
