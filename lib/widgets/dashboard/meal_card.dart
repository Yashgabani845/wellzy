import 'package:flutter/material.dart';
import 'package:healthify/models/dashboard_model.dart';
import 'package:healthify/theme/app_colors.dart';

import 'package:go_router/go_router.dart';
import 'package:healthify/routing/routes.dart';

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.addFood),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: meal.isCompleted ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: meal.isCompleted ? null : Border.all(color: AppColors.border, width: 1.5, style: BorderStyle.solid), // Dashed effect can be simulated, using solid for now
        boxShadow: meal.isCompleted ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Icon or Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: meal.isCompleted ? AppColors.border : AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              image: meal.isCompleted && meal.imagePath != null
                  ? DecorationImage(image: AssetImage(meal.imagePath!), fit: BoxFit.cover)
                  : null,
            ),
            child: !meal.isCompleted || meal.imagePath == null
                ? const Icon(Icons.restaurant, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Trailing action or calories
          if (meal.isCompleted)
            Text(
              '${meal.calories} kcal',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
        ],
      ),
    ));
  }
}
