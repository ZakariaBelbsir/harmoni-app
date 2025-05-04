import 'package:flutter/material.dart';

class AppColors {
  static Color mainColor = Color(0xFF6D9EEB);
  static Color secondaryColor = Color(0xFFB8A1E3);
  static Color paleMint = Color(0xffA8E6CF);
  static Color offWhite = Color(0xFFF5F5F5);
  static Color darkGray = Color(0xFF4A4A4A);
  static Color error = Color(0xFFDC143C);
  static Color cardColor = Color(0xFFB6B6B6);
}

ThemeData primaryTheme = ThemeData(
    // Font Family
    fontFamily: 'Satoshi',
    // Seed Color
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mainColor),
    // Scaffold Color
    scaffoldBackgroundColor: AppColors.offWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.mainColor,
      foregroundColor: AppColors.darkGray,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.darkGray,
        fontSize: 16,
        letterSpacing: 1,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkGray,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      titleMedium: TextStyle(
        color: AppColors.offWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),
    // Cart Theme
    cardTheme: CardTheme(
      color: AppColors.cardColor.withAlpha((0.3 * 255).toInt()),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      shadowColor: Colors.transparent,
      margin: EdgeInsets.only(bottom: 16),
    ));
