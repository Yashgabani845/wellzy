import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_constants.dart';
import 'package:healthify/theme/app_text_styles.dart';

class OnboardingPage3 extends StatefulWidget {
  final double currentHeight; // in cm
  final double currentWeight; // in kg
  final bool isHeightCm;
  final bool isWeightKg;
  final Function(double, bool) onHeightChanged;
  final Function(double, bool) onWeightChanged;

  const OnboardingPage3({
    super.key,
    required this.currentHeight,
    required this.currentWeight,
    required this.isHeightCm,
    required this.isWeightKg,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  
  // For ft/in separate fields
  late TextEditingController _ftController;
  late TextEditingController _inController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _ftController = TextEditingController();
    _inController = TextEditingController();
    
    _syncFields();
  }

  void _syncFields() {
    if (widget.isHeightCm) {
      _heightController.text = widget.currentHeight.toStringAsFixed(0);
    } else {
      // cm to feet/inches
      final totalInches = widget.currentHeight / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      _ftController.text = feet.toString();
      _inController.text = inches.toString();
    }

    if (widget.isWeightKg) {
      _weightController.text = widget.currentWeight.toStringAsFixed(1);
    } else {
      // kg to lbs
      final lbs = widget.currentWeight * 2.20462;
      _weightController.text = lbs.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ftController.dispose();
    _inController.dispose();
    super.dispose();
  }

  void _onHeightCmChange(String val) {
    final double? cm = double.tryParse(val);
    if (cm != null) {
      widget.onHeightChanged(cm, true);
    }
  }

  void _onHeightFtInChange() {
    final double? ft = double.tryParse(_ftController.text);
    final double? inches = double.tryParse(_inController.text);
    if (ft != null) {
      final totalInches = (ft * 12) + (inches ?? 0);
      final cm = totalInches * 2.54;
      widget.onHeightChanged(cm, false);
    }
  }

  void _onWeightChange(String val) {
    final double? weightVal = double.tryParse(val);
    if (weightVal != null) {
      if (widget.isWeightKg) {
        widget.onWeightChanged(weightVal, true);
      } else {
        // lbs to kg
        final kg = weightVal / 2.20462;
        widget.onWeightChanged(kg, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your height\n& weight?',
            style: AppTextStyles.largeHeading.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We use this to establish standard baseline metabolic levels.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 32),
  
          // Height Header & Unit Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HEIGHT',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              // Toggle
              Container(
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _UnitToggleItem(
                      label: 'cm',
                      isActive: widget.isHeightCm,
                      onTap: () {
                        if (!widget.isHeightCm) {
                          widget.onHeightChanged(widget.currentHeight, true);
                          setState(() {
                            _syncFields();
                          });
                        }
                      },
                    ),
                    _UnitToggleItem(
                      label: 'ft/in',
                      isActive: !widget.isHeightCm,
                      onTap: () {
                        if (widget.isHeightCm) {
                          widget.onHeightChanged(widget.currentHeight, false);
                          setState(() {
                            _syncFields();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
  
          // Height Inputs
          if (widget.isHeightCm)
            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              style: AppTextStyles.subSectionHeading.copyWith(fontSize: 18),
              onChanged: _onHeightCmChange,
              decoration: const InputDecoration(
                hintText: 'Height',
                suffixText: 'cm',
                prefixIcon: Icon(Icons.height),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ftController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.subSectionHeading.copyWith(fontSize: 18),
                    onChanged: (_) => _onHeightFtInChange(),
                    decoration: const InputDecoration(
                      hintText: 'Feet',
                      suffixText: 'ft',
                      prefixIcon: Icon(Icons.height),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _inController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.subSectionHeading.copyWith(fontSize: 18),
                    onChanged: (_) => _onHeightFtInChange(),
                    decoration: const InputDecoration(
                      hintText: 'Inches',
                      suffixText: 'in',
                      prefixIcon: Icon(Icons.height),
                    ),
                  ),
                ),
              ],
            ),
  
          const SizedBox(height: 32),
  
          // Weight Header & Unit Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEIGHT',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              // Toggle
              Container(
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _UnitToggleItem(
                      label: 'kg',
                      isActive: widget.isWeightKg,
                      onTap: () {
                        if (!widget.isWeightKg) {
                          widget.onWeightChanged(widget.currentWeight, true);
                          setState(() {
                            _syncFields();
                          });
                        }
                      },
                    ),
                    _UnitToggleItem(
                      label: 'lbs',
                      isActive: !widget.isWeightKg,
                      onTap: () {
                        if (widget.isWeightKg) {
                          widget.onWeightChanged(widget.currentWeight, false);
                          setState(() {
                            _syncFields();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
  
          // Weight Input
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.subSectionHeading.copyWith(fontSize: 18),
            onChanged: _onWeightChange,
            decoration: InputDecoration(
              hintText: 'Weight',
              suffixText: widget.isWeightKg ? 'kg' : 'lbs',
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitToggleItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _UnitToggleItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
