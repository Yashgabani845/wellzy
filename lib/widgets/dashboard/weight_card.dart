import 'package:flutter/material.dart';
import 'package:healthify/models/dashboard_model.dart';
import 'package:healthify/theme/app_colors.dart';

class WeightCard extends StatelessWidget {
  final WeightData data;

  const WeightCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.monitor_weight_outlined, color: AppColors.primaryDark, size: 18),
              SizedBox(width: 6),
              Text('Weight', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.current}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Text(
                ' kg',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          // Custom Bar Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.last5Days.asMap().entries.map((entry) {
              int idx = entry.key;
              double weight = entry.value;
              bool isLatest = idx == data.last5Days.length - 1;
              // Normalize height for the mini chart
              double minWeight = 70.0;
              double heightFactor = (weight - minWeight) / 10.0; // Assume variation between 70 and 80 for demo
              heightFactor = heightFactor.clamp(0.2, 1.0);
              
              return Container(
                width: 16,
                height: 40 * heightFactor,
                decoration: BoxDecoration(
                  color: isLatest ? AppColors.primaryDark : AppColors.border,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: isLatest ? const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: CircleAvatar(radius: 2, backgroundColor: Colors.white),
                  ),
                ) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
