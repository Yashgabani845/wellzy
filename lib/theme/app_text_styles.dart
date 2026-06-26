import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // Large Heading - Bold
  static const TextStyle largeHeading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 28.0,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Section Heading - SemiBold
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20.0,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // Subsection Heading - SemiBold
  static const TextStyle subSectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 16.0,
    color: AppColors.textPrimary,
  );

  // Body - Medium
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 15.0,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 15.0,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Caption - Regular
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12.0,
    color: AppColors.textLight,
  );

  static const TextStyle captionSecondary = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12.0,
    color: AppColors.textSecondary,
  );

  // Button text - SemiBold
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 16.0,
    color: AppColors.secondary,
    letterSpacing: 0.2,
  );
}
