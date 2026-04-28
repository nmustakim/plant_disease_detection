import 'package:flutter/material.dart';

import '../../services/translation/translation_service.dart';

class AppColors {
  // Primary brand palette — deep forest green
  static const Color primary = Color(0xFF1A6B3C);
  static const Color primaryLight = Color(0xFF2D9E5F);
  static const Color primaryDark = Color(0xFF0D4A28);
  static const Color primaryMuted = Color(0xFFE8F5EE);

  // Secondary / accent
  static const Color secondary = Color(0xFF52B788);
  static const Color accent = Color(0xFFFFC947);
  static const Color accentWarm = Color(0xFFFF8C42);

  // Dark theme primaries
  static const Color secondaryDark = Color(0xFF40916C);
  static const Color accentDark = Color(0xFF74C69D);

  // Confidence colors
  static const Color highConfidence = Color(0xFF2D9E5F);
  static const Color mediumConfidence = Color(0xFFE8971A);
  static const Color lowConfidence = Color(0xFFD62839);

  // Status colors
  static const Color success = Color(0xFF2D9E5F);
  static const Color warning = Color(0xFFE8971A);
  static const Color error = Color(0xFFD62839);
  static const Color info = Color(0xFF2979FF);

  // Light theme surfaces
  static const Color background = Color(0xFFF7FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFEDF7F1);
  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color divider = Color(0xFFE0EDE6);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF0D1A12);
  static const Color surfaceDark = Color(0xFF152218);
  static const Color surfaceElevatedDark = Color(0xFF1E3328);
  static const Color onSurfaceDark = Color(0xFFE8F5EE);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A6058);
  static const Color textHint = Color(0xFF8AA89A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dark theme text
  static const Color textPrimaryDark = Color(0xFFE8F5EE);
  static const Color textSecondaryDark = Color(0xFF9DC4B0);
  static const Color textHintDark = Color(0xFF5A7A68);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6B3C), Color(0xFF0D4A28)],
  );

  static const LinearGradient freshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D9E5F), Color(0xFF1A6B3C)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDF7F1), Color(0xFFF7FAF8)],
  );

  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.85) return highConfidence;
    if (confidence >= 0.60) return mediumConfidence;
    return lowConfidence;
  }

  static String getConfidenceLabel(double confidence) {
    if (confidence >= 0.85) return 'high_confidence'.tr;
    if (confidence >= 0.60) return 'medium_confidence'.tr;
    return 'low_confidence'.tr;
  }
}

