import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  static TranslationService get instance => _instance;

  TranslationService._internal();

  static const String _localeKey = 'app_locale';

  Map<String, String> _strings = {};
  String _currentLanguage = 'en';

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('bn', ''),
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_localeKey) ?? 'en';
    await loadLanguage(savedLanguage);
  }

  Future<void> loadLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (e) {
      debugPrint('Failed to load translations for $languageCode: $e');
    }
  }

  String translate(String key) {
    return _strings[key] ?? key;
  }

  String get currentLanguage => _currentLanguage;

  Locale get currentLocale => Locale(_currentLanguage, '');

  Future<void> setLanguage(String languageCode) async {
    await loadLanguage(languageCode);
  }

  bool isBengali() => _currentLanguage == 'bn';
  bool isEnglish() => _currentLanguage == 'en';
}

extension StringTranslation on String {
  String get tr {
    return TranslationService.instance.translate(this);
  }
}