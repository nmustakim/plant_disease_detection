import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF66BB6A);
  static const Color accent = Color(0xFF4CAF50);

  // Dark theme colors
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color secondaryDark = Color(0xFF4CAF50);
  static const Color accentDark = Color(0xFF66BB6A);

  // Confidence colors (same for both themes)
  static const Color highConfidence = Color(0xFF4CAF50);
  static const Color mediumConfidence = Color(0xFFFFA726);
  static const Color lowConfidence = Color(0xFFEF5350);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Light theme surfaces
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212121);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Dark theme text colors
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF757575);

  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.85) return highConfidence;
    if (confidence >= 0.60) return mediumConfidence;
    return lowConfidence;
  }

  static String getConfidenceLabel(double confidence) {
    if (confidence >= 0.85) return 'High';
    if (confidence >= 0.60) return 'Medium';
    return 'Low';
  }
}