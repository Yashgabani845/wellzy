import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6BCB77);
  static const Color primaryDark = Color(0xFF2D5A27); // Darker, premium green
  static const Color primaryLight = Color(0xFFE8F8E6);
  static const Color secondary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FFF8);
  static const Color card = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  
  static const Color border = Color(0xFFE5EBE5);
  static const Color borderFocused = Color(0xFF6BCB77);
  
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);

  // Gradient definitions
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6BCB77), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient softGradient = LinearGradient(
    colors: [Color(0xFFF0FFF0), Color(0xFFE8F8E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
