import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/my_health_controller.dart';
import 'package:healthify/models/my_health_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:printing/printing.dart';

import 'widgets/health_score_card.dart';
import 'widgets/body_metrics_cards.dart';
import 'widgets/nutrition_analysis_cards.dart';
import 'widgets/insights_recommendations_cards.dart';
import 'widgets/edit_medical_profile_sheet.dart';
import 'utils/my_health_pdf_generator.dart';

class MyHealthScreen extends StatefulWidget {
  const MyHealthScreen({super.key});

  @override
  State<MyHealthScreen> createState() => _MyHealthScreenState();
}

class _MyHealthScreenState extends State<MyHealthScreen> with SingleTickerProviderStateMixin {
  final MyHealthController _controller = Get.put(MyHealthController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showEditProfile(BuildContext context, MyHealthData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditMedicalProfileSheet(
        initialProfile: data.medicalProfile,
        onSave: (updated) {
          _controller.updateMedicalProfile(updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GetBuilder<MyHealthController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing your health stats...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = controller.healthData;
          if (data == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text('Error loading health profile', style: AppTextStyles.sectionHeading),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => controller.fetchData(),
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.fetchData(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: AppColors.background,
                    elevation: 0,
                    pinned: true,
                    centerTitle: false,
                    title: Row(
                      children: [
                        Icon(Icons.favorite_rounded, color: AppColors.primary, size: 28),
                        const SizedBox(width: 8),
                        const Text('My Health', style: AppTextStyles.largeHeading),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.file_download_rounded, color: AppColors.primaryDark),
                        tooltip: 'Export Weekly PDF Report',
                        onPressed: () async {
                          try {
                            final pdfBytes = await MyHealthPdfGenerator.generateWeeklyReport(data);
                            await Printing.layoutPdf(
                              onLayout: (format) async => pdfBytes,
                              name: 'wellzy_weekly_health_report.pdf',
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Export Failed',
                              'Could not generate report: $e',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  // Health Content in Modular Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Health Score Card
                          HealthScoreCard(data: data),
                          const SizedBox(height: 16),

                          // 2. Body Composition Card
                          BodyCompositionCard(data: data),
                          const SizedBox(height: 16),

                          // 3. Nutrition Quality Card
                          NutritionQualityCard(data: data),
                          const SizedBox(height: 16),

                          // 4. Daily Nutrition Breakdown
                          DailyNutritionBreakdown(data: data),
                          const SizedBox(height: 16),

                          // 5. Nutrition Balance
                          NutritionBalanceCard(data: data),
                          const SizedBox(height: 16),

                          // 6. Potential Nutrient Gaps
                          NutrientGapsCard(data: data),
                          const SizedBox(height: 16),

                          // 7. Eating Pattern Analysis
                          EatingPatternCard(data: data),
                          const SizedBox(height: 16),

                          // 8. Food Quality Analysis
                          FoodQualityCard(data: data),
                          const SizedBox(height: 16),

                          // 9. Lifestyle Assessment
                          LifestyleAssessmentCard(data: data),
                          const SizedBox(height: 16),

                          // 10. Smart Insights
                          SmartInsightsCard(data: data),
                          const SizedBox(height: 16),

                          // 11. Personalized Recommendations
                          RecommendationsCard(data: data),
                          const SizedBox(height: 16),

                          // 12. Health Risk Indicators
                          RiskIndicatorsCard(data: data),
                          const SizedBox(height: 16),

                          // 13. Health Timeline
                          HealthTimelineCard(data: data),
                          const SizedBox(height: 16),

                          // 14. Medical Profile (Tap to Edit)
                          MedicalProfileCard(
                            data: data,
                            onTap: () => _showEditProfile(context, data),
                          ),
                          const SizedBox(height: 16),

                          // 15. Wellness Achievements
                          AchievementsCard(data: data),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
