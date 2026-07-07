import 'package:flutter/material.dart';
import 'package:healthify/models/my_health_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class BodyCompositionCard extends StatelessWidget {
  final MyHealthData data;

  const BodyCompositionCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double bmiValue = double.parse(data.bmi.toStringAsFixed(1));
    final bmiColor = data.bmiCategory == 'Healthy'
        ? AppColors.primary
        : data.bmiCategory == 'Underweight'
            ? Colors.blue
            : Colors.orange;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Body Composition', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(
                icon: Icons.monitor_weight_outlined,
                title: 'Weight',
                value: '${data.currentWeight.toStringAsFixed(1)} kg',
                color: Colors.blue,
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.textLight),
              _buildMetricItem(
                icon: Icons.flag_outlined,
                title: 'Goal',
                value: '${data.goalWeight.toStringAsFixed(1)} kg',
                color: Colors.green,
              ),
              _buildMetricItem(
                icon: Icons.speed_outlined,
                title: 'BMI',
                value: '$bmiValue',
                color: bmiColor,
                subtitle: data.bmiCategory,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_down_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.weightTrendMsg,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(title, style: AppTextStyles.caption),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}

class MedicalProfileCard extends StatelessWidget {
  final MyHealthData data;
  final VoidCallback onTap;

  const MedicalProfileCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Medical Profile', style: AppTextStyles.subSectionHeading),
                    Icon(Icons.edit_note_rounded, color: AppColors.primaryDark),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMedicalRow(Icons.bloodtype_outlined, 'Blood Group', data.medicalProfile.bloodGroup, Colors.red),
                _buildMedicalRow(Icons.restaurant_menu_outlined, 'Diet', data.medicalProfile.diet, Colors.green),
                _buildMedicalRow(Icons.no_food_outlined, 'Allergies', data.medicalProfile.allergies, Colors.orange),
                _buildMedicalRow(Icons.health_and_safety_outlined, 'Conditions', data.medicalProfile.conditions, Colors.purple),
                _buildMedicalRow(Icons.flag_circle_outlined, 'Goal', data.medicalProfile.goal, Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class HealthTimelineCard extends StatelessWidget {
  final MyHealthData data;

  const HealthTimelineCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double weightVal = data.healthTimeline['weight'] ?? 0.0;
    final int scoreVal = data.healthTimeline['score'] ?? 0;
    final int proteinVal = data.healthTimeline['protein'] ?? 0;
    final int waterVal = data.healthTimeline['water'] ?? 0;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Timeline', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 4),
          Text('Summary of improvement this month', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineItem('Weight', '${weightVal > 0 ? "+" : ""}${weightVal.toStringAsFixed(1)} kg', weightVal < 0, Colors.blue),
              _buildTimelineItem('Score', '${scoreVal > 0 ? "+" : ""}$scoreVal Points', scoreVal >= 0, Colors.orange),
              _buildTimelineItem('Protein', '${proteinVal > 0 ? "+" : ""}$proteinVal%', proteinVal >= 0, Colors.green),
              _buildTimelineItem('Water', '${waterVal > 0 ? "+" : ""}$waterVal%', waterVal >= 0, Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value, bool isPositive, Color color) {
    return Column(
      children: [
        Icon(
          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: isPositive ? AppColors.primary : Colors.redAccent,
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class AchievementsCard extends StatelessWidget {
  final MyHealthData data;

  const AchievementsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wellness Achievements', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          ...data.wellnessAchievements.map((achievement) {
            final isCompleted = achievement['status'] == 'Completed' || achievement['status'].toString().contains('Active');
            IconData iconData = Icons.star_border_rounded;
            switch (achievement['iconName']) {
              case 'star':
                iconData = Icons.star_rounded;
                break;
              case 'check_circle':
                iconData = Icons.check_circle_rounded;
                break;
              case 'water_drop':
                iconData = Icons.water_drop_rounded;
                break;
              case 'flag':
                iconData = Icons.flag_rounded;
                break;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primaryLight : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: isCompleted ? AppColors.primaryDark : AppColors.textLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement['status'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? AppColors.primaryDark : AppColors.textSecondary,
                            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
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
  );
}
