import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // Corner Radii
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double textFieldRadius = 16.0;
  static const double bottomSheetRadius = 28.0;

  // BorderRadius objects
  static final BorderRadius borderRadiusCard = BorderRadius.circular(cardRadius);
  static final BorderRadius borderRadiusButton = BorderRadius.circular(buttonRadius);
  static final BorderRadius borderRadiusTextField = BorderRadius.circular(textFieldRadius);
  static final BorderRadius borderRadiusBottomSheet = BorderRadius.circular(bottomSheetRadius);

  // Soft Shadows
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: const Color(0xFF6BCB77).withValues(alpha: 0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
}
