import 'package:flutter/material.dart';


class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF66BB6A);
  static const Color accent = Color(0xFF4CAF50);

  static const Color highConfidence = Color(0xFF4CAF50);
  static const Color mediumConfidence = Color(0xFFFFA726);
  static const Color lowConfidence = Color(0xFFEF5350);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212121);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

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