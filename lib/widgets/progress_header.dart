import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onSkip;
  final bool showSkip;

  const ProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onSkip,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step progress indicator dots or lines
          Row(
            children: List.generate(totalSteps, (index) {
              final bool isPassed = index < currentStep;
              final bool isCurrent = index == currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isCurrent ? 24 : 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isCurrent
                      ? AppColors.primary
                      : isPassed
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.border,
                ),
              );
            }),
          ),
          // Skip Button
          if (showSkip && onSkip != null)
            GestureDetector(
              onTap: onSkip,
              child: Text(
                'Skip',
                style: AppTextStyles.bodySecondary.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            const SizedBox(width: 40), // Spacer placeholder
        ],
      ),
    );
  }
}
