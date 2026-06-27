import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthify/routing/routes.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class AddEntryBottomSheet extends StatelessWidget {
  const AddEntryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'What would you like to track?',
            style: AppTextStyles.largeHeading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1, // Slightly wider than tall
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
                _buildActionCard(
                  context,
                  title: 'Add a Meal',
                  icon: Icons.restaurant,
                  color: AppColors.primaryDark,
                  route: AppRoutes.addFood,
                ),
                _buildActionCard(
                  context,
                  title: 'Scan Barcode',
                  icon: Icons.qr_code_scanner,
                  color: Colors.blueAccent,
                  route: AppRoutes.scanBarcode,
                ),
                _buildActionCard(
                  context,
                  title: 'Update Weight',
                  icon: Icons.monitor_weight_outlined,
                  color: Colors.purple,
                  route: AppRoutes.updateWeight,
                ),
                _buildActionCard(
                  context,
                  title: 'Log Exercise',
                  icon: Icons.fitness_center,
                  color: Colors.orange,
                  route: AppRoutes.addExercise,
                ),
                _buildActionCard(
                  context,
                  title: 'Log Water',
                  icon: Icons.water_drop_outlined,
                  color: Colors.cyan,
                  route: AppRoutes.logWater,
                ),
                _buildActionCard(
                  context,
                  title: 'Log Sleep',
                  icon: Icons.nights_stay,
                  color: const Color(0xFF5C6BC0),
                  route: AppRoutes.addSleep,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required String route}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        context.push(route); // Navigate to specific screen
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
