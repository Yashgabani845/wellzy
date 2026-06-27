import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/progress_controller.dart';
import 'package:healthify/models/progress_model.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/common/empty_state_widget.dart';
import 'dart:ui' as ui;

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressController _controller = Get.put(ProgressController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProgressController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Progress', style: AppTextStyles.sectionHeading),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildTimeSelector(controller),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async => await controller.fetchData(),
            color: AppColors.primary,
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _buildContent(controller),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Time Selector Segmented Control
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTimeSelector(ProgressController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: controller.periods.map((period) {
            final isSelected = controller.selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setPeriod(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryDark : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    period,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Main Content
  // ═══════════════════════════════════════════════════════════════
  Widget _buildContent(ProgressController controller) {
    if (controller.data == null || (controller.data!.weightTrends.isEmpty && controller.data!.nutritionTrends.isEmpty)) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: EmptyStateWidget(
                icon: Icons.trending_up,
                title: 'No Progress Data',
                message: 'Log your meals and weight to see your progress over time.',
              ),
            ),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Weight Trend Chart
          _buildWeightChartSection(controller.data!.weightTrends),
          const SizedBox(height: 32),
          // Averages Grid
          _buildSummaryGrid(controller.data!.summary),
          const SizedBox(height: 32),
          // Nutrition Breakdown Chart
          _buildNutritionChartSection(controller.data!.nutritionTrends),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Weight Chart Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWeightChartSection(List<WeightDataPoint> trends) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weight Trend', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          Container(
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _WeightChartPainter(trends: trends),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Summary Grid Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSummaryGrid(ProgressSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Period Averages', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildGridCard('Calories', '${summary.avgCalories} kcal', Icons.local_fire_department, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildGridCard('Water', '${summary.avgWaterLiters} L', Icons.water_drop, Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGridCard(
                  'Net Weight', 
                  '${summary.netWeightChange > 0 ? '+' : ''}${summary.netWeightChange.toStringAsFixed(1)} kg', 
                  Icons.monitor_weight, 
                  summary.netWeightChange <= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildGridCard('Consistency', '${summary.consistencyPercentage}%', Icons.check_circle, Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Nutrition Chart Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildNutritionChartSection(List<NutritionDataPoint> trends) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Calorie Intake', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _NutritionChartPainter(trends: trends),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Custom Painters for Charts
// ═══════════════════════════════════════════════════════════════

class _WeightChartPainter extends CustomPainter {
  final List<WeightDataPoint> trends;

  _WeightChartPainter({required this.trends});

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final double minWeight = trends.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 1.0;
    final double maxWeight = trends.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 1.0;
    final double weightRange = maxWeight - minWeight;

    final double stepX = size.width / (trends.length > 1 ? trends.length - 1 : 1);
    
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < trends.length; i++) {
      final x = i * stepX;
      // Invert Y axis (0 is top)
      final y = size.height - ((trends[i].weight - minWeight) / weightRange) * size.height;
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Create smooth curve
        final prev = points[i - 1];
        final current = points[i];
        final controlPoint1 = Offset((prev.dx + current.dx) / 2, prev.dy);
        final controlPoint2 = Offset((prev.dx + current.dx) / 2, current.dy);
        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, current.dx, current.dy);
      }
    }

    // 1. Draw Gradient Fill under the line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [
          AppColors.primaryDark.withValues(alpha: 0.3),
          AppColors.primaryDark.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw the thick line
    final linePaint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // 3. Draw dots on data points
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) => true;
}

class _NutritionChartPainter extends CustomPainter {
  final List<NutritionDataPoint> trends;

  _NutritionChartPainter({required this.trends});

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final maxCals = trends.map((e) => e.calorieGoal * 1.2).reduce((a, b) => a > b ? a : b); // Ensure bars fit
    final int dataCount = trends.length;
    
    // Calculate bar width and spacing
    final double spacing = size.width * 0.05; // 5% spacing
    final double totalSpacing = spacing * (dataCount - 1);
    final double barWidth = (size.width - totalSpacing) / dataCount;
    
    for (int i = 0; i < trends.length; i++) {
      final data = trends[i];
      final x = i * (barWidth + spacing);
      
      // Goal background (light grey bar showing the goal height)
      final goalY = size.height - (data.calorieGoal / maxCals) * size.height;
      final goalRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, goalY, barWidth, size.height - goalY),
        const Radius.circular(6),
      );
      final goalPaint = Paint()..color = Colors.grey.withValues(alpha: 0.15);
      canvas.drawRRect(goalRect, goalPaint);

      // Consumed (colored bar)
      final consumedY = size.height - (data.caloriesConsumed / maxCals) * size.height;
      
      // Color logic: green if under goal, red/orange if over goal
      Color barColor;
      if (data.isWithinGoal) {
        barColor = Colors.green[400]!;
      } else {
        barColor = Colors.orange[400]!;
      }

      final consumedRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, consumedY, barWidth, size.height - consumedY),
        const Radius.circular(6),
      );
      final consumedPaint = Paint()..color = barColor;
      canvas.drawRRect(consumedRect, consumedPaint);
    }

    // Draw target line across the chart
    final targetLineY = size.height - (trends.first.calorieGoal / maxCals) * size.height;
    final targetLinePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw dashed line
    const double dashWidth = 5;
    const double dashSpace = 5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, targetLineY),
        Offset(startX + dashWidth, targetLineY),
        targetLinePaint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _NutritionChartPainter oldDelegate) => true;
}
