import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<Locale> kSupportedLocales = [
  Locale('en', 'US'),
  Locale('bn', 'BD'),
];

const String _kLocaleKey = 'app_locale';
const String _kDefaultLanguage = 'en';


class TranslationService extends ChangeNotifier {
  TranslationService._internal();

  static final TranslationService instance = TranslationService._internal();


  Map<String, String> _strings = {};
  String _currentLanguage = _kDefaultLanguage;
  bool _isInitialized = false;


  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;
  bool get isBengali => _currentLanguage == 'bn';
  bool get isEnglish => _currentLanguage == 'en';

  Locale get currentLocale => Locale(_currentLanguage, '');



  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_kLocaleKey) ?? _kDefaultLanguage;
    await _loadBundle(savedLanguage, persist: false); // already persisted
    _isInitialized = true;
  }

  Future<void> loadLanguage(String languageCode) async {
    if (languageCode == _currentLanguage && _strings.isNotEmpty) return;
    await _loadBundle(languageCode, persist: true);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) => loadLanguage(languageCode);

  String translate(String key) => _strings[key] ?? key;


  Future<void> _loadBundle(String languageCode, {required bool persist}) async {
    final effectiveCode = _isSupportedLanguage(languageCode)
        ? languageCode
        : _kDefaultLanguage;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$effectiveCode.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _strings = jsonMap.map((k, v) => MapEntry(k, v.toString()));
      _currentLanguage = effectiveCode;

      if (persist) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kLocaleKey, effectiveCode);
      }
    } catch (e) {
      debugPrint('[TranslationService] Failed to load bundle for '
          '"$effectiveCode": $e');
    }
  }

  bool _isSupportedLanguage(String code) =>
      kSupportedLocales.any((l) => l.languageCode == code);
}


extension StringTranslation on String {
  String get tr => TranslationService.instance.translate(this);
}