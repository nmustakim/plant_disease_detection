
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const Color _primaryGreen    = Color(0xFF2E7D32);
  static const Color _accentGreen     = Color(0xFF4CAF50);
  static const Color _backgroundLight = Color(0xFFF1F8E9);
  static const Color highConfidenceColor = Color(0xFF4CAF50);
  static const Color medConfidenceColor  = Color(0xFFFFC107);
  static const Color lowConfidenceColor  = Color(0xFFF44336);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryGreen, primary: _primaryGreen,
      secondary: _accentGreen, brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(backgroundColor: _primaryGreen, foregroundColor: Colors.white, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    scaffoldBackgroundColor: _backgroundLight,
    fontFamily: 'Roboto',
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _primaryGreen, brightness: Brightness.dark),
    fontFamily: 'Roboto',
  );

  static Color confidenceColor(double confidence) {
    if (confidence >= 0.85) return highConfidenceColor;
    if (confidence >= 0.60) return medConfidenceColor;
    return lowConfidenceColor;
  }
}
