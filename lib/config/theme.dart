import 'package:flutter/material.dart';

/// Палитра под макет Y MIX: тёмно-синий фон, сине-фиолетовый градиент логотипа.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF1B2A4A);
  static const Color navyDark = Color(0xFF13203A);
  static const Color cardLight = Color(0xFFEDEDF1);
  static const Color bubbleMine = Color(0xFF5B7BA6);
  static const Color bubbleOther = Color(0xFFE7E7EC);
  static const Color accentPurple = Color(0xFF8A6BFF);
  static const Color accentBlue = Color(0xFF4E7BD8);

  static const List<Color> logoGradient = [accentBlue, accentPurple];
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentBlue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      fontFamily: 'Roboto',
    );
  }
}
