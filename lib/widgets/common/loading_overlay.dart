import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'dart:ui';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({super.key, this.message = 'Saving...'});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A cool animated bar instead of a circle
                  const SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.primaryLight,
                      color: AppColors.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
