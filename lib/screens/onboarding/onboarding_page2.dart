import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_constants.dart';
import 'package:healthify/theme/app_text_styles.dart';

class OnboardingPage2 extends StatelessWidget {
  final String selectedGender;
  final Function(String) onGenderSelected;
  final int selectedAge;
  final Function(int) onAgeSelected;

  const OnboardingPage2({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
    required this.selectedAge,
    required this.onAgeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> genders = ['Male', 'Female', 'Prefer not to say'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about\nyourself',
          style: AppTextStyles.largeHeading.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This helps us customize your calorie and metabolism calculations.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 32),
        
        // Gender Header
        Text(
          'GENDER',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        
        // Gender Cards List
        Column(
          children: genders.map((gender) {
            final bool isSelected = selectedGender == gender;
            return GestureDetector(
              onTap: () => onGenderSelected(gender),
              child: AnimatedContainer(
                duration: AppConstants.durationNormal,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.card,
                  borderRadius: AppConstants.borderRadiusCard,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      gender,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off_outlined,
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Age Picker Header
        Text(
          'AGE',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // Beautiful Wheel Age Picker
        Expanded(
          child: Center(
            child: SizedBox(
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center selection indicators
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  ListWheelScrollView.useDelegate(
                    itemExtent: 44,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      onAgeSelected(12 + index); // Starting age is 12
                    },
                    controller: FixedExtentScrollController(initialItem: selectedAge - 12),
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final int age = 12 + index;
                        final bool isCurrent = age == selectedAge;
                        return Center(
                          child: Text(
                            '$age years',
                            style: AppTextStyles.largeHeading.copyWith(
                              fontSize: isCurrent ? 20 : 16,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          ),
                        );
                      },
                      childCount: 89, // from 12 to 100
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
