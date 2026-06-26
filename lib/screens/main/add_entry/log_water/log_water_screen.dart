import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/log_water_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class LogWaterScreen extends StatefulWidget {
  const LogWaterScreen({super.key});

  @override
  State<LogWaterScreen> createState() => _LogWaterScreenState();
}

class _LogWaterScreenState extends State<LogWaterScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  final LogWaterController _controller = Get.put(LogWaterController());

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _addWaterWithAnimation(int amount) {
    _controller.addWater(amount);
    _pulseController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LogWaterController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Hydration', style: AppTextStyles.sectionHeading),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ─── Progress Ring + Glass ────────────────
                      _buildGlassSection(controller),
                      const SizedBox(height: 36),

                      // ─── Quick Add Grid ───────────────────────
                      _buildQuickAddSection(controller),
                      const SizedBox(height: 32),

                      // ─── Weekly Overview ──────────────────────
                      _buildWeeklyOverview(controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Glass Section — Circular progress ring around a water drop
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGlassSection(LogWaterController controller) {
    return Column(
      children: [
        // Intake display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: controller.currentIntakeMl.toDouble()),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -2,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            Text(
              '/ ${controller.dailyGoalMl} ml',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Circular Water Container
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress Ring (background)
              SizedBox(
                width: 220,
                height: 220,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: controller.progress),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: value,
                        trackColor: Colors.blue.withOpacity(0.08),
                        progressColor: const Color(0xFF42A5F5),
                      ),
                    );
                  },
                ),
              ),

              // Inner circle with wave
              Container(
                width: 180,
                height: 180,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF42A5F5).withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated water fill
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: controller.progress),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, animValue, child) {
                        return AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(180, 180),
                              painter: _WavePainter(
                                wavePhase: _waveController.value,
                                fillPercent: animValue,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Center content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 32,
                          color: controller.progress > 0.5 
                              ? Colors.white 
                              : const Color(0xFF42A5F5),
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: controller.progress),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            return Text(
                              '${(value * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: value > 0.5 
                                    ? Colors.white 
                                    : const Color(0xFF1E88E5),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Remaining text
        Text(
          controller.progress >= 1.0
              ? '🎉 Goal reached!'
              : '${controller.dailyGoalMl - controller.currentIntakeMl} ml remaining',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: controller.progress >= 1.0 ? AppColors.primaryDark : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Quick Add Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickAddSection(LogWaterController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Add', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickChip(controller, '150 ml', 150, Icons.local_drink_outlined),
              const SizedBox(width: 10),
              _buildQuickChip(controller, '250 ml', 250, Icons.coffee_outlined),
              const SizedBox(width: 10),
              _buildQuickChip(controller, '500 ml', 500, Icons.water_drop_outlined),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildQuickChip(controller, '1 Liter', 1000, Icons.opacity),
              const SizedBox(width: 10),
              _buildCustomChip(context, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(LogWaterController controller, String label, int amount, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addWaterWithAnimation(amount),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: const Color(0xFF42A5F5), size: 24),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomChip(BuildContext context, LogWaterController controller) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showCustomAddDialog(context, controller),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.25), width: 1.5),
          ),
          child: const Column(
            children: [
              Icon(Icons.add_circle_outline, color: Color(0xFF1E88E5), size: 24),
              SizedBox(height: 8),
              Text(
                'Custom',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Weekly Overview
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWeeklyOverview(LogWaterController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
                const Text('This Week', style: AppTextStyles.subSectionHeading),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(color: Color(0xFF42A5F5), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildDayBar('M', 0.6),
                _buildDayBar('T', 0.8),
                _buildDayBar('W', 1.0),
                _buildDayBar('T', 0.4),
                _buildDayBar('F', 0.9),
                _buildDayBar('S', 0.7),
                _buildDayBar('S', controller.progress, isToday: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBar(String day, double percentage, {bool isToday = false}) {
    final clamped = percentage.clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 100,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return FractionallySizedBox(
                heightFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isToday
                          ? [const Color(0xFF42A5F5), const Color(0xFF1E88E5)]
                          : [const Color(0xFF90CAF9), const Color(0xFF64B5F6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 28,
          height: 28,
          decoration: isToday
              ? BoxDecoration(
                  color: const Color(0xFF42A5F5),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              color: isToday ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Custom Add Dialog
  // ═══════════════════════════════════════════════════════════════
  void _showCustomAddDialog(BuildContext context, LogWaterController controller) {
    final TextEditingController amountInput = TextEditingController();
    String unit = 'ml';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Add Custom Amount',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountInput,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey[300]),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: unit,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            borderRadius: BorderRadius.circular(16),
                            items: const [
                              DropdownMenuItem(value: 'ml', child: Text('ml', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                              DropdownMenuItem(value: 'L', child: Text('L', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                            ],
                            onChanged: (val) {
                              if (val != null) setSheetState(() => unit = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final double? amount = double.tryParse(amountInput.text);
                        if (amount != null && amount > 0) {
                          final int ml = unit == 'L' ? (amount * 1000).toInt() : amount.toInt();
                          _addWaterWithAnimation(ml);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Add Water', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Custom Painters
// ═══════════════════════════════════════════════════════════════

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _WavePainter extends CustomPainter {
  final double wavePhase;
  final double fillPercent;

  _WavePainter({required this.wavePhase, required this.fillPercent});

  @override
  void paint(Canvas canvas, Size size) {
    if (fillPercent <= 0) return;

    final fillHeight = size.height * (1 - fillPercent); // Top of the water

    // Wave path
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = fillHeight +
          math.sin((x / size.width * 2 * math.pi) + (wavePhase * 2 * math.pi)) * 6 +
          math.sin((x / size.width * 4 * math.pi) + (wavePhase * 2 * math.pi * 1.5)) * 3;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Gradient fill
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF64B5F6).withOpacity(0.7),
          const Color(0xFF42A5F5).withOpacity(0.85),
          const Color(0xFF1E88E5),
        ],
      ).createShader(Rect.fromLTWH(0, fillHeight, size.width, size.height - fillHeight));

    canvas.drawPath(path, paint);

    // Second wave (lighter, slightly offset)
    final path2 = Path();
    path2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = fillHeight +
          math.sin((x / size.width * 2 * math.pi) + (wavePhase * 2 * math.pi) + math.pi) * 4 +
          math.cos((x / size.width * 3 * math.pi) + (wavePhase * 2 * math.pi * 0.8)) * 2;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.close();

    final paint2 = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.3);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
