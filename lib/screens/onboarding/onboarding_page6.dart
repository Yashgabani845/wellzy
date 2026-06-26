import 'package:flutter/material.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/chip_selector.dart';

class OnboardingPage6 extends StatelessWidget {
  final List<String> selectedDiets;
  final Function(List<String>) onDietsChanged;

  const OnboardingPage6({
    super.key,
    required this.selectedDiets,
    required this.onDietsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> diets = [
      'Vegetarian',
      'Vegan',
      'Eggetarian',
      'Non-Vegetarian',
      'Jain',
      'No Preference',
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any diet\npreferences?',
            style: AppTextStyles.largeHeading.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose one or more options. We will filter recipe recommendation suggestions accordingly.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 40),
          
          // Multi select grid
          Center(
            child: ChipSelector(
              options: diets,
              selectedOptions: selectedDiets,
              onChange: onDietsChanged,
            ),
          ),
        ],
      ),
    );
  }
}
