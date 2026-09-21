import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // =========================
  // APP COLORS
  // =========================

  static const Color primaryColor = Color(0xFF176B5B);
  static const Color primaryLight = Color(0xFFE2F3EE);
  static const Color darkText = Color(0xFF16332D);
  static const Color secondaryText = Color(0xFF64736F);
  static const Color backgroundColor = Color(0xFFF7FAF9);

  // =========================
  // LIGHT THEME
  // =========================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: backgroundColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
    ),

    // =========================
    // TEXT FIELD THEME
    // =========================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    ),

    // =========================
    // BUTTON THEME
    // =========================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,

        minimumSize: const Size(
          double.infinity,
          54,
        ),

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}