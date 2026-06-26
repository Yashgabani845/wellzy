import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/weight_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class UpdateWeightScreen extends StatefulWidget {
  const UpdateWeightScreen({super.key});

  @override
  State<UpdateWeightScreen> createState() => _UpdateWeightScreenState();
}

class _UpdateWeightScreenState extends State<UpdateWeightScreen> {
  final WeightController _controller = Get.put(WeightController());
  late ScrollController _rulerScrollController;
  final double _tickWidth = 12.0; // pixels per 0.1 kg

  @override
  void initState() {
    super.initState();
    _rulerScrollController = ScrollController();
    // After first frame, scroll to current weight
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeight(_controller.currentWeight, animate: false);
    });
  }

  @override
  void dispose() {
    _rulerScrollController.dispose();
    super.dispose();
  }

  void _scrollToWeight(double weight, {bool animate = true}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = ((weight - 30.0) * 10 * _tickWidth) - (screenWidth / 2);
    if (animate) {
      _rulerScrollController.animateTo(
        offset.clamp(0.0, _rulerScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      if (_rulerScrollController.hasClients) {
        _rulerScrollController.jumpTo(
          offset.clamp(0.0, _rulerScrollController.position.maxScrollExtent),
        );
      }
    }
  }

  void _onRulerScroll() {
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = _rulerScrollController.offset + (screenWidth / 2);
    final weight = 30.0 + (offset / (_tickWidth * 10));
    final snapped = (weight * 10).roundToDouble() / 10; // Snap to 0.1
    _controller.setWeight(snapped.clamp(30.0, 200.0));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WeightController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        // Scroll to loaded weight on first build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_rulerScrollController.hasClients) return;
          if (_rulerScrollController.position.pixels == 0) {
            _scrollToWeight(controller.currentWeight, animate: false);
          }
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Update Weight', style: AppTextStyles.sectionHeading),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Hero Weight Display
                      _buildHeroWeight(controller),
                      const SizedBox(height: 40),

                      // Scroll Ruler
                      _buildScrollRuler(controller),
                      const SizedBox(height: 40),

                      // BMI Card
                      _buildBmiCard(controller),
                      const SizedBox(height: 32),

                      // Trend Graph
                      _buildTrendGraph(controller),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Save Button (pinned at bottom)
              _buildSaveButton(controller),
            ],
          ),
        );
      },
    );
  }

  // ─── Hero Weight ──────────────────────────────────────────────
  Widget _buildHeroWeight(WeightController controller) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: controller.currentWeight),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -2,
              ),
            );
          },
        ),
        const Text('kg', style: TextStyle(fontSize: 22, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: controller.weightDifference > 0
                ? Colors.orange.withOpacity(0.1)
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            controller.weightDifference > 0
                ? '${controller.weightDifference.toStringAsFixed(1)} kg above goal'
                : controller.weightDifference == 0
                    ? '🎯 At your goal!'
                    : '${controller.weightDifference.abs().toStringAsFixed(1)} kg below goal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: controller.weightDifference > 0
                  ? Colors.orange[700]
                  : AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Scroll Ruler ─────────────────────────────────────────────
  Widget _buildScrollRuler(WeightController controller) {
    // Range: 30 kg to 200 kg → 1700 * 10 ticks
    const double minWeight = 30.0;
    const double maxWeight = 200.0;
    final int totalTicks = ((maxWeight - minWeight) * 10).toInt();
    final double totalWidth = totalTicks * _tickWidth;

    return Column(
      children: [
        const Text('Slide to set weight', style: AppTextStyles.caption),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ruler
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    _onRulerScroll();
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _rulerScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: totalWidth + MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2),
                    child: CustomPaint(
                      size: Size(totalWidth, 80),
                      painter: _RulerPainter(
                        tickWidth: _tickWidth,
                        totalTicks: totalTicks,
                        minWeight: minWeight,
                      ),
                    ),
                  ),
                ),
              ),
              // Center indicator
              IgnorePointer(
                child: Container(
                  width: 3,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Top triangle indicator
              Positioned(
                top: 0,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: const Size(16, 10),
                    painter: _TrianglePainter(color: AppColors.primaryDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── BMI Card ─────────────────────────────────────────────────
  Widget _buildBmiCard(WeightController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Body Mass Index', style: AppTextStyles.subSectionHeading),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: controller.bmi),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gradient bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 12,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF64B5F6), // Underweight - Blue
                      Color(0xFF81C784), // Normal - Green
                      Color(0xFFFFB74D), // Overweight - Orange
                      Color(0xFFE57373), // Obese - Red
                    ],
                    stops: [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Marker
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: controller.bmiPosition),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Align(
                  alignment: Alignment(-1.0 + (2.0 * value), 0),
                  child: Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryDark, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Labels
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Underweight', style: TextStyle(fontSize: 10, color: Color(0xFF64B5F6), fontWeight: FontWeight.w600)),
                Text('Normal', style: TextStyle(fontSize: 10, color: Color(0xFF81C784), fontWeight: FontWeight.w600)),
                Text('Overweight', style: TextStyle(fontSize: 10, color: Color(0xFFFFB74D), fontWeight: FontWeight.w600)),
                Text('Obese', style: TextStyle(fontSize: 10, color: Color(0xFFE57373), fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),

            // Category label
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _getBmiColor(controller.bmiCategory).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.bmiCategory,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _getBmiColor(controller.bmiCategory),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBmiColor(String category) {
    switch (category) {
      case 'Underweight': return const Color(0xFF64B5F6);
      case 'Normal': return const Color(0xFF81C784);
      case 'Overweight': return const Color(0xFFFFB74D);
      case 'Obese': return const Color(0xFFE57373);
      default: return AppColors.textSecondary;
    }
  }

  // ─── Trend Graph ──────────────────────────────────────────────
  Widget _buildTrendGraph(WeightController controller) {
    if (controller.entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weight Trend', style: AppTextStyles.subSectionHeading),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: const Size(double.infinity, 150),
                painter: _TrendChartPainter(
                  entries: controller.entries,
                  primaryColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Date labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: controller.entries.map((e) {
                final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(
                  dayNames[e.date.weekday - 1],
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Save Button ──────────────────────────────────────────────
  Widget _buildSaveButton(WeightController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isSaving ? null : () async {
            await controller.saveWeight();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Weight saved: ${controller.currentWeight.toStringAsFixed(1)} kg'),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: controller.isSaving
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Custom Painters
// ═══════════════════════════════════════════════════════════════

class _RulerPainter extends CustomPainter {
  final double tickWidth;
  final int totalTicks;
  final double minWeight;

  _RulerPainter({required this.tickWidth, required this.totalTicks, required this.minWeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;

    final boldPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= totalTicks; i++) {
      final x = i * tickWidth;
      final isMajor = i % 10 == 0; // Every 1 kg
      final isMid = i % 5 == 0 && !isMajor; // Every 0.5 kg

      double tickHeight;
      if (isMajor) {
        tickHeight = 40;
        canvas.drawLine(Offset(x, size.height - tickHeight), Offset(x, size.height), boldPaint);

        // Draw weight label
        final weight = minWeight + (i / 10);
        textPainter.text = TextSpan(
          text: weight.toInt().toString(),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - tickHeight - 18));
      } else if (isMid) {
        tickHeight = 25;
        canvas.drawLine(Offset(x, size.height - tickHeight), Offset(x, size.height), paint);
      } else {
        tickHeight = 14;
        canvas.drawLine(Offset(x, size.height - tickHeight), Offset(x, size.height), paint..strokeWidth = 1.0);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendChartPainter extends CustomPainter {
  final List entries;
  final Color primaryColor;

  _TrendChartPainter({required this.entries, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final weights = entries.map((e) => e.weightKg as double).toList();
    final minW = weights.reduce(math.min) - 0.5;
    final maxW = weights.reduce(math.max) + 0.5;
    final range = maxW - minW;

    final points = <Offset>[];
    for (int i = 0; i < weights.length; i++) {
      final x = (i / (weights.length - 1)) * size.width;
      final y = size.height - ((weights[i] - minW) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Draw gradient fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Smooth curve using cubic bezier
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()..color = primaryColor;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 6, dotBorderPaint);
      canvas.drawCircle(p, 5, dotPaint);
    }

    // Draw weight labels on dots
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < points.length; i++) {
      tp.text = TextSpan(
        text: weights[i].toStringAsFixed(1),
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      );
      tp.layout();
      tp.paint(canvas, Offset(points[i].dx - tp.width / 2, points[i].dy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
