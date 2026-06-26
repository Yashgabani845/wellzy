import 'package:flutter/material.dart';
import 'package:healthify/models/dashboard_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class OverviewCard extends StatelessWidget {
  final DashboardModel data;

  const OverviewCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutQuart,
            builder: (context, animValue, child) {
              final animatedConsumed = (data.caloriesConsumed * animValue).toInt();
              final animatedProgress = data.caloriesProgress * animValue;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today\'s Overview', style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$animatedConsumed',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' / ${data.caloriesTarget} kcal',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${data.caloriesRemaining} kcal remaining', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                    ],
                  ),
                  // Circular Progress
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 10,
                          color: AppColors.primaryLight,
                        ),
                        CircularProgressIndicator(
                          value: animatedProgress,
                          strokeWidth: 10,
                          color: AppColors.primary,
                          strokeCap: StrokeCap.round,
                        ),
                        const Center(
                          child: Icon(Icons.local_fire_department_rounded, color: AppColors.primaryDark, size: 30),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
          const SizedBox(height: 32),
          // Macros
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutQuart,
            builder: (context, animValue, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMacroBar('Protein', '${data.protein.remaining}g left', data.protein.progress * animValue, AppColors.primaryDark),
                  _buildMacroBar('Carbs', '${data.carbs.remaining}g left', data.carbs.progress * animValue, Colors.amber),
                  _buildMacroBar('Fat', '${data.fat.remaining}g left', data.fat.progress * animValue, Colors.deepOrangeAccent),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String title, String subtitle, double progress, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              color: color,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
