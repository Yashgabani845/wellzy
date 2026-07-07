import 'package:flutter/material.dart';
import 'package:healthify/models/my_health_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class NutritionQualityCard extends StatelessWidget {
  final MyHealthData data;

  const NutritionQualityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nutrition Quality', style: AppTextStyles.subSectionHeading),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < data.nutritionQualityStars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGradeTag('Protein', data.proteinGrade),
              _buildGradeTag('Fiber', data.fiberGrade),
              _buildGradeTag('Healthy Fat', data.fatGrade),
              _buildGradeTag('Added Sugar', data.sugarGrade, invert: true),
              _buildGradeTag('Sodium', data.sodiumGrade, invert: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeTag(String label, String grade, {bool invert = false}) {
    final bool isExcellent = grade == 'Excellent' || grade == 'Balanced' || (invert && grade == 'Low');
    final bool isGood = grade == 'Good' || (invert && grade == 'Moderate');
    
    final Color color = isExcellent
        ? AppColors.primary
        : isGood
            ? Colors.orange
            : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExcellent ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $grade',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class DailyNutritionBreakdown extends StatelessWidget {
  final MyHealthData data;

  const DailyNutritionBreakdown({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Nutrition Breakdown', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          _buildLinearProgress('Protein', data.proteinPercent, AppColors.primary),
          _buildLinearProgress('Fiber', data.fiberPercent, Colors.teal),
          _buildLinearProgress('Water', data.waterPercent, Colors.blue),
          _buildLinearProgress('Sugar', data.sugarPercent, Colors.purple, isLimit: true),
          _buildLinearProgress('Calories', data.caloriesPercent, Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildLinearProgress(String label, double ratio, Color color, {bool isLimit = false}) {
    final int percent = (ratio * 100).round();
    final double displayVal = ratio.clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(
                '$percent%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLimit && ratio > 1.0 ? Colors.redAccent : color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: displayVal,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLimit && ratio > 1.0 ? Colors.redAccent : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionBalanceCard extends StatelessWidget {
  final MyHealthData data;

  const NutritionBalanceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nutrition Balance', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _buildBalanceGridItem('Carbs', data.carbsBalance, Colors.amber),
              _buildBalanceGridItem('Protein', data.proteinBalance, Colors.green),
              _buildBalanceGridItem('Fat', data.fatBalance, Colors.blue),
              _buildBalanceGridItem('Fiber', data.fiberBalance, Colors.teal),
              _buildBalanceGridItem('Sugar', data.sugarBalance, Colors.purple),
              _buildBalanceGridItem('Sodium', data.sodiumBalance, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceGridItem(String nutrient, String status, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              nutrient,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: status == 'High' || status == 'Low' ? Colors.redAccent : color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class NutrientGapsCard extends StatelessWidget {
  final MyHealthData data;

  const NutrientGapsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Potential Nutrient Gaps', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 4),
          Text(
            'Based on food items logged in the last 7 days (estimates)',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          if (data.nutrientGapsLow.isNotEmpty) ...[
            const Text('Likely Low', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
            const SizedBox(height: 8),
            ...data.nutrientGapsLow.map((gap) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(gap, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],
          if (data.nutrientGapsGood.isNotEmpty) ...[
            const Text('Good / Sufficient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            ...data.nutrientGapsGood.map((gap) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(gap, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],
          if (data.nutrientGapsIncrease.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text('Suggested Foods to Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.nutrientGapsIncrease.map((food) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_rounded, size: 12, color: AppColors.primaryDark),
                        const SizedBox(width: 6),
                        Text(
                          food,
                          style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class EatingPatternCard extends StatelessWidget {
  final MyHealthData data;

  const EatingPatternCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Eating Pattern Analysis', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          ...data.mealPatterns.entries.map((entry) {
            final isWarning = entry.value.contains('Skipped') || entry.value.contains('Late') || entry.value.contains('High');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isWarning ? Colors.amber.shade50 : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: isWarning ? Colors.orange.shade900 : AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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

class FoodQualityCard extends StatelessWidget {
  final MyHealthData data;

  const FoodQualityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Food Quality Analysis', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 4),
          Text('Last 30 Days Quality Breakdown', style: AppTextStyles.caption),
          const SizedBox(height: 20),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (data.wholeFoodRatio * 100).round().clamp(1, 100),
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: (data.processedFoodRatio * 100).round().clamp(1, 100),
                    child: Container(color: Colors.orange),
                  ),
                  Expanded(
                    flex: (data.ultraProcessedRatio * 100).round().clamp(1, 100),
                    child: Container(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQualityLegend('Whole Foods', data.wholeFoodRatio, AppColors.primary),
              _buildQualityLegend('Processed', data.processedFoodRatio, Colors.orange),
              _buildQualityLegend('Ultra Processed', data.ultraProcessedRatio, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                data.foodQualityFeedback,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityLegend(String title, double ratio, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          '$title: ${(ratio * 100).round()}%',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
      ],
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
