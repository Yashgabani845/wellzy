import 'package:flutter/material.dart';


class NutriTheme {
  // Color Palette
  static const Color primaryGreen = Color(0xFFA7E3A1);
  static const Color darkForestGreen = Color(0xFF184D2F);
  static const Color mintGreen = Color(0xFFE8F8E6);
  static const Color surfaceBackground = Color(0xFFFAFCFA);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color surfaceContainer = Color(0xFFE8F1E7);
  static const Color onSurfaceVariant = Color(0xFF424940);
  static const Color outline = Color(0xFF72796F);

  // Design Tokens
  static const double borderRadius = 24.0;
  static const String fontFamily = 'Manrope';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: darkForestGreen,
        onPrimary: pureWhite,
        primaryContainer: primaryGreen,
        onPrimaryContainer: darkForestGreen,
        secondary: primaryGreen,
        onSecondary: darkForestGreen,
        surface: surfaceBackground,
        onSurface: darkForestGreen,
        surfaceContainer: surfaceContainer,
        outline: outline,
      ),
      scaffoldBackgroundColor: surfaceBackground,
      fontFamily: fontFamily,

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: darkForestGreen,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: darkForestGreen,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: darkForestGreen,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: darkForestGreen,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: darkForestGreen,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: darkForestGreen,
        ),
      ),

      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 2,
        shadowColor: darkForestGreen.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkForestGreen,
          foregroundColor: pureWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          elevation: 0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        hintStyle: TextStyle(
          color: outline.withValues(alpha: 0.5),
          fontFamily: fontFamily,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: darkForestGreen,
        ),
        iconTheme: IconThemeData(color: darkForestGreen),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: darkForestGreen,
        unselectedItemColor: outline,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily),
      ),
    );
  }
}
