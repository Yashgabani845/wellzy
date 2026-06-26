import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_constants.dart';
import 'package:healthify/theme/app_text_styles.dart';

class ChipSelector extends StatelessWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onChange;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onChange,
  });

  void _onSelected(String option, bool selected) {
    final List<String> newSelected = List.from(selectedOptions);
    if (selected) {
      newSelected.add(option);
    } else {
      newSelected.remove(option);
    }
    onChange(newSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: options.map((option) {
        final bool isSelected = selectedOptions.contains(option);
        return GestureDetector(
          onTap: () => _onSelected(option, !isSelected),
          child: AnimatedContainer(
            duration: AppConstants.durationNormal,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
