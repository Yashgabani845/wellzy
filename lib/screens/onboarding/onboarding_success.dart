import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_spacing.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/metric_card.dart';
import 'package:healthify/widgets/primary_button.dart';

class OnboardingSuccess extends StatelessWidget {
  final VoidCallback onStartJourney;

  const OnboardingSuccess({
    super.key,
    required this.onStartJourney,
  });

  Future<Map<String, dynamic>> _fetchGoals() async {
    final authController = Get.find<AuthController>();
    final uid = authController.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('info')
        .get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    }
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Success Vector Header
              Center(
                child: CustomPaint(
                  size: const Size(120, 120),
                  painter: SuccessBadgePainter(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "You're all set!",
                style: AppTextStyles.largeHeading.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Here is your AI-calculated nutritional targets baseline.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Summary Cards Grid
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fetchGoals(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final data = snapshot.data ?? <String, dynamic>{};
                    final calories = data['dailyCaloriesGoal']?.toString() ?? '2,050';
                    final protein = data['dailyProteinGoal']?.toString() ?? '140';
                    final carbs = data['dailyCarbsGoal']?.toString() ?? '220';
                    final fat = data['dailyFatGoal']?.toString() ?? '65';
                    final timeline = data['estimatedTimelineWeeks']?.toString() ?? '14';

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        MetricCard(
                          title: 'DAILY CALORIE TARGET',
                          value: calories,
                          unit: 'kcal',
                          icon: Icons.local_fire_department_rounded,
                          accentColor: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        MetricCard(
                          title: 'PROTEIN',
                          value: protein,
                          unit: 'g',
                          icon: Icons.egg_alt_outlined,
                          accentColor: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        MetricCard(
                          title: 'CARBOHYDRATES',
                          value: carbs,
                          unit: 'g',
                          icon: Icons.grain_rounded,
                          accentColor: Colors.amber,
                        ),
                        const SizedBox(height: 12),
                        MetricCard(
                          title: 'DIETARY FATS',
                          value: fat,
                          unit: 'g',
                          icon: Icons.opacity_rounded,
                          accentColor: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        MetricCard(
                          title: 'ESTIMATED GOAL TIMELINE',
                          value: timeline,
                          unit: 'Weeks',
                          icon: Icons.calendar_month_outlined,
                          accentColor: AppColors.primary,
                        ),
                      ],
                    );
                  },
                ),
              ),

              AppSpacing.gapHmd,
              // Start Journey Button
              PrimaryButton(
                text: 'Start My Journey',
                onPressed: onStartJourney,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.42;

    // Green circular badge fill
    final Paint circlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8F8E6), Color(0xFFC8E6C9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    // Inner ring border
    final Paint ringPaint = Paint()
      ..color = const Color(0xFF6BCB77).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(cx, cy), r - 6, ringPaint);

    // Dynamic Leaf decorations
    final Paint decorationPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Drawing leaf icons on circles or checkmark
    final Paint checkPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final Path checkPath = Path()
      ..moveTo(cx - w * 0.18, cy + h * 0.02)
      ..lineTo(cx - w * 0.04, cy + h * 0.15)
      ..lineTo(cx + w * 0.22, cy - h * 0.12);

    canvas.drawPath(checkPath, checkPaint);

    // Top leaf sprigs
    final Path leftLeaf = Path()
      ..moveTo(cx - r, cy - r * 0.2)
      ..quadraticBezierTo(cx - r * 1.2, cy - r * 0.7, cx - r * 0.8, cy - r * 0.9)
      ..quadraticBezierTo(cx - r * 0.6, cy - r * 0.5, cx - r, cy - r * 0.2)
      ..close();
    canvas.drawPath(leftLeaf, decorationPaint);

    final Path rightLeaf = Path()
      ..moveTo(cx + r, cy - r * 0.2)
      ..quadraticBezierTo(cx + r * 1.2, cy - r * 0.7, cx + r * 0.8, cy - r * 0.9)
      ..quadraticBezierTo(cx + r * 0.6, cy - r * 0.5, cx + r, cy - r * 0.2)
      ..close();
    canvas.drawPath(rightLeaf, decorationPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
