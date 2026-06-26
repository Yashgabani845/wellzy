import 'package:flutter/material.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/selection_card.dart';

class OnboardingPage1 extends StatelessWidget {
  final String selectedGoal;
  final Function(String) onGoalSelected;

  const OnboardingPage1({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> goals = [
      {
        'title': 'Lose Weight',
        'subtitle': 'Burn fat, get leaner, and improve metabolism',
        'icon': Icons.trending_down_rounded,
      },
      {
        'title': 'Gain Muscle',
        'subtitle': 'Build strength, mass, and muscle tone',
        'icon': Icons.fitness_center_rounded,
      },
      {
        'title': 'Maintain Weight',
        'subtitle': 'Keep current weight while improving body profile',
        'icon': Icons.sync_rounded,
      },
      {
        'title': 'Improve Fitness',
        'subtitle': 'Enhance endurance, flexibility, and energy levels',
        'icon': Icons.speed_rounded,
      },
      {
        'title': 'Eat Healthier',
        'subtitle': 'Build better food habits and clean diet rules',
        'icon': Icons.restaurant_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What brings you\nto Wellzy?',
          style: AppTextStyles.largeHeading.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the primary goal you want to focus on.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final String title = goal['title'] as String;
              return SelectionCard(
                title: title,
                subtitle: goal['subtitle'] as String?,
                icon: goal['icon'] as IconData,
                isSelected: selectedGoal == title,
                onTap: () => onGoalSelected(title),
              );
            },
          ),
        ),
      ],
    );
  }
}
