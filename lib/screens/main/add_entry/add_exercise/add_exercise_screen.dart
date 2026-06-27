import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthify/controllers/exercise_controller.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';
import 'package:healthify/widgets/common/loading_overlay.dart';
import 'dart:math' as math;

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final ExerciseController _controller = Get.put(ExerciseController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExerciseController>(
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
            title: const Text('Log Exercise', style: AppTextStyles.sectionHeading),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
    
                          // ─── Today's Burn Summary ─────────────────
                          _buildBurnSummary(controller),
                          const SizedBox(height: 28),
    
                          // ─── Category Tabs ────────────────────────
                          _buildCategoryTabs(controller),
                          const SizedBox(height: 20),
    
                          // ─── Exercise List ────────────────────────
                          _buildExerciseList(controller),
                          const SizedBox(height: 28),
    
                          // ─── Duration Picker ──────────────────────
                          if (controller.selectedExercise != null)
                            _buildDurationPicker(controller),
    
                          // ─── Today's Log ──────────────────────────
                          if (controller.todayEntries.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            _buildTodayLog(controller),
                          ],
                        ],
                      ),
                    ),
                  ),
    
                  // ─── Log Button (pinned) ──────────────────────────
                  if (controller.selectedExercise != null)
                    _buildLogButton(controller),
                ],
              ),
              if (controller.isLogging)
                const LoadingOverlay(message: 'Logging Exercise...'),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Burn Summary — calories ring + stats
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBurnSummary(ExerciseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Calorie Ring
            SizedBox(
              width: 80,
              height: 80,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: controller.goalProgress),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: _BurnRingPainter(progress: value),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                          Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),

            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Burn",
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: controller.totalCaloriesBurned.toDouble()),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          );
                        },
                      ),
                      Text(
                        ' / ${controller.dailyGoalCalories} kcal',
                        style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white60, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.totalMinutes} min active',
                        style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Category Tabs
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCategoryTabs(ExerciseController controller) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () => controller.selectCategory(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? null : Border.all(color: AppColors.border),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    category.id == 'cardio' ? Icons.directions_run :
                    category.id == 'strength' ? Icons.fitness_center :
                    category.id == 'flexibility' ? Icons.self_improvement :
                    Icons.sports_soccer,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
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

  // ═══════════════════════════════════════════════════════════════
  // Exercise List
  // ═══════════════════════════════════════════════════════════════
  Widget _buildExerciseList(ExerciseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Exercise', style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85, // Taller cards for images
            ),
            itemCount: controller.currentExercises.length,
            itemBuilder: (context, index) {
              final exercise = controller.currentExercises[index];
              final isSelected = controller.selectedExercise?.id == exercise.id;

              return GestureDetector(
                onTap: () => controller.selectExercise(exercise),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
                        : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Section
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                color: const Color(0xFFF9F9F9),
                                child: exercise.imageAsset.isNotEmpty
                                    ? Image.asset(
                                        exercise.imageAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.fitness_center, color: AppColors.textLight, size: 40),
                                      )
                                    : const Icon(Icons.fitness_center, color: AppColors.textLight, size: 40),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Text Section
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 14,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '~${exercise.caloriesPerMinute} kcal/min',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Duration Picker
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDurationPicker(ExerciseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Duration', style: AppTextStyles.subSectionHeading),
                Text(
                  '${controller.durationMinutes} min',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.1),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: controller.durationMinutes.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                onChanged: (value) => controller.setDuration(value.toInt()),
              ),
            ),

            // Quick duration chips
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [15, 30, 45, 60, 90].map((min) {
                  final isActive = controller.durationMinutes == min;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => controller.setDuration(min),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${min}m',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isActive ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Estimated calories
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated burn: ',
                    style: TextStyle(color: Colors.orange[800], fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: controller.estimatedCalories.toDouble()),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toInt()} kcal',
                        style: TextStyle(color: Colors.orange[900], fontSize: 16, fontWeight: FontWeight.w800),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Today's Log
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTodayLog(ExerciseController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Activity", style: AppTextStyles.subSectionHeading),
          const SizedBox(height: 12),
          ...controller.todayEntries.map((entry) {
            final hour = entry.date.hour;
            final minute = entry.date.minute.toString().padLeft(2, '0');
            final period = hour >= 12 ? 'PM' : 'AM';
            final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.durationMinutes} min · $displayHour:$minute $period',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${entry.caloriesBurned} kcal',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  // ═══════════════════════════════════════════════════════════════
  // Log Button
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLogButton(ExerciseController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLogging
              ? null
              : () async {
                  await controller.logExercise();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Exercise logged! 🔥'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 8),
              Text(
                'Log ${controller.selectedExercise?.name ?? "Exercise"} · ${controller.estimatedCalories} kcal',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Burn Ring Painter
// ═══════════════════════════════════════════════════════════════
class _BurnRingPainter extends CustomPainter {
  final double progress;
  _BurnRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BurnRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
