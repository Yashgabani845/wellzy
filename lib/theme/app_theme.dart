import 'package:flutter/material.dart';
import 'package:healthify/theme/app_colors.dart';
import 'package:healthify/theme/app_constants.dart';
import 'package:healthify/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.secondary,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.primary,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.secondary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.fontFamily,
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.largeHeading,
        displayMedium: AppTextStyles.largeHeading,
        headlineLarge: AppTextStyles.largeHeading,
        headlineMedium: AppTextStyles.sectionHeading,
        titleMedium: AppTextStyles.subSectionHeading,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        labelLarge: AppTextStyles.button,
        bodySmall: AppTextStyles.caption,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadiusCard,
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusTextField,
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusTextField,
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusTextField,
          borderSide: const BorderSide(color: AppColors.borderFocused, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusTextField,
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusTextField,
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        labelStyle: AppTextStyles.bodySecondary,
        hintStyle: AppTextStyles.caption,
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.bottomSheetRadius),
            topRight: Radius.circular(AppConstants.bottomSheetRadius),
          ),
        ),
      ),
    );
  }
}
