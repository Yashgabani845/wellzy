import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:healthify/models/dashboard_model.dart';
import 'package:healthify/theme/app_colors.dart';

class WaterCard extends StatefulWidget {
  final WaterData data;

  const WaterCard({super.key, required this.data});

  @override
  State<WaterCard> createState() => _WaterCardState();
}

class _WaterCardState extends State<WaterCard> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Animated Fluid Background
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.data.progress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutQuart,
            builder: (context, animValue, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final fillHeight = constraints.maxHeight * animValue;
                  // We draw a tall liquid block. The top is covered by spinning squircles masking it, 
                  // or we just spin squircles of liquid color.
                  // A simple wave: An animated builder that rotates a shape.
                  return AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: fillHeight,
                            color: Colors.lightBlue[100],
                          ),
                          Positioned(
                            bottom: fillHeight - 10, // slightly above the fill level
                            child: Transform.rotate(
                              angle: _waveController.value * 2 * math.pi,
                              child: Container(
                                width: constraints.maxWidth * 2.5,
                                height: constraints.maxWidth * 2.5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(constraints.maxWidth * 1.05), // creates a soft squircle
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: fillHeight - 15,
                            child: Transform.rotate(
                              angle: _waveController.value * 2 * math.pi + math.pi / 4,
                              child: Container(
                                width: constraints.maxWidth * 2.5,
                                height: constraints.maxWidth * 2.5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(constraints.maxWidth * 1.1), 
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop_outlined, color: Colors.blue[600], size: 18),
                    const SizedBox(width: 6),
                    const Text('Water', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: widget.data.consumed),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          '/${widget.data.total}L',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    );
                  }
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
