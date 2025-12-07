import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Clean purple for a clean white-based theme
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryVariant = Color(0xFF5A4BCC);
  static const Color onPrimary = Colors.white;

  // Secondary colors
  static const Color secondary = Color(0xFF4285F4);
  static const Color secondaryVariant = Color(0xFF3367D6);
  static const Color onSecondary = Colors.white;

  // Background colors - Focused on clean white
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);

  // Error colors
  static const Color error = Color(0xFFD93025);
  static const Color onError = Colors.white;

  // Light theme specific
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF1A1A1A);

  // Dark theme specific
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white;

  // Additional colors for UI elements
  static const Color cardBackground = Color(
    0xFFF8F9FA,
  ); // Very light grey for subtle contrast
  static const Color appBarBackground = Color(0xFFFFFFFF);
  static const Color appBarText = Color(0xFF1A1A1A);
  static const Color checkedBox = Color(
    0xFF34A853,
  ); // Clean green for checklists
  static const Color uncheckedBox = Color(0xFFCCCCCC);
  static const Color disabled = Color(0xFFE0E0E0);

  // Status colors
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFF9AB00);
  static const Color info = Color(0xFF4285F4);
}
