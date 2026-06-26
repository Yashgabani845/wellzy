import 'package:flutter/material.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/activity_card.dart';

class OnboardingPage5 extends StatelessWidget {
  final String selectedActivity;
  final Function(String) onActivitySelected;

  const OnboardingPage5({
    super.key,
    required this.selectedActivity,
    required this.onActivitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Sedentary',
        'description': 'Little to no exercise, desk job or lying down mostly',
        'icon': Icons.weekend_outlined,
      },
      {
        'title': 'Lightly Active',
        'description': 'Light exercise/sports 1-3 days/week, active at home',
        'icon': Icons.directions_walk_rounded,
      },
      {
        'title': 'Moderately Active',
        'description': 'Moderate exercise/sports 3-5 days/week, jogging, cycling',
        'icon': Icons.directions_run_rounded,
      },
      {
        'title': 'Very Active',
        'description': 'Hard exercise/sports 6-7 days/week, heavy lifting',
        'icon': Icons.bolt_rounded,
      },
      {
        'title': 'Athlete',
        'description': 'Very intense physical activity, double training sessions',
        'icon': Icons.sports_gymnastics_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your daily\nactivity level?',
          style: AppTextStyles.largeHeading.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This determines how many baseline calories your body burns at rest.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final String title = activity['title'] as String;
              return ActivityCard(
                title: title,
                description: activity['description'] as String,
                icon: activity['icon'] as IconData,
                isSelected: selectedActivity == title,
                onTap: () => onActivitySelected(title),
              );
            },
          ),
        ),
      ],
    );
  }
}
