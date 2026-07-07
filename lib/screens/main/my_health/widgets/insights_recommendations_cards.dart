import 'package:flutter/material.dart';
import 'package:healthify/models/my_health_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class LifestyleAssessmentCard extends StatelessWidget {
  final MyHealthData data;

  const LifestyleAssessmentCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lifestyle Assessment', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          ...data.lifestyleRatings.entries.map((entry) {
            final int fullStars = entry.value.floor();
            final bool hasHalf = (entry.value - fullStars) >= 0.5;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        if (index < fullStars) {
                          return const Icon(Icons.star_rounded, color: Colors.amber, size: 18);
                        } else if (index == fullStars && hasHalf) {
                          return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 18);
                        } else {
                          return const Icon(Icons.star_border_rounded, color: AppColors.border, size: 18);
                        }
                      }),
                      const SizedBox(width: 6),
                      Text(
                        entry.value.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
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

class SmartInsightsCard extends StatelessWidget {
  final MyHealthData data;

  const SmartInsightsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Smart Insights', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          if (data.smartInsights.isEmpty)
            const Text('We are analyzing your logs. Log more meals to unlock daily smart insights.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
          else
            ...data.smartInsights.map((insight) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            insight,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class RecommendationsCard extends StatelessWidget {
  final MyHealthData data;

  const RecommendationsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Recommendations", style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          ...data.personalizedRecommendations.map((rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class RiskIndicatorsCard extends StatelessWidget {
  final MyHealthData data;

  const RiskIndicatorsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.healthRiskIndicators.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Risk Indicators', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 4),
          Text('Lifestyle indicators (non-medical estimates)', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          ...data.healthRiskIndicators.map((risk) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${risk['title']} (${risk['days']} Days)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            risk['message'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.red.shade900, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
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
