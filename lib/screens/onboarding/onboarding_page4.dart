import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_text_styles.dart';

class OnboardingPage4 extends StatefulWidget {
  final double targetWeight; // in kg
  final bool isWeightKg;
  final Function(double) onTargetWeightChanged;

  const OnboardingPage4({
    super.key,
    required this.targetWeight,
    required this.isWeightKg,
    required this.onTargetWeightChanged,
  });

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  late TextEditingController _targetWeightController;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController();
    _syncText();
  }

  void _syncText() {
    if (widget.isWeightKg) {
      _targetWeightController.text = widget.targetWeight.toStringAsFixed(1);
    } else {
      final lbs = widget.targetWeight * 2.20462;
      _targetWeightController.text = lbs.toStringAsFixed(1);
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingPage4 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWeightKg != widget.isWeightKg || oldWidget.targetWeight != widget.targetWeight) {
      _syncText();
    }
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    final double? weightVal = double.tryParse(val);
    if (weightVal != null) {
      if (widget.isWeightKg) {
        widget.onTargetWeightChanged(weightVal);
      } else {
        final kg = weightVal / 2.20462;
        widget.onTargetWeightChanged(kg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayWeight = widget.isWeightKg ? widget.targetWeight : (widget.targetWeight * 2.20462);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your target\nweight?',
            style: AppTextStyles.largeHeading.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We will calibrate your target timeline based on this weight goal.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 48),
  
          // Centered Display Card showing targeted details
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TARGET WEIGHT GOAL',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayWeight.toStringAsFixed(1),
                      style: AppTextStyles.largeHeading.copyWith(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isWeightKg ? 'kg' : 'lbs',
                      style: AppTextStyles.largeHeading.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
  
          // Text field input
          TextField(
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.subSectionHeading.copyWith(fontSize: 18),
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'Enter target weight',
              suffixText: widget.isWeightKg ? 'kg' : 'lbs',
              prefixIcon: const Icon(Icons.ads_click_outlined),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Custom message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'A healthy pace is losing/gaining 0.5 - 1 kg per week, which is highly sustainable.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
