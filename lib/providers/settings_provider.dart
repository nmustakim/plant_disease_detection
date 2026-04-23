
import 'package:flutter/foundation.dart';
import '../controllers/settings_controller.dart';
import '../data/models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsController _controller;
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  SettingsProvider(this._controller) {
    _load();
  }

  Future<void> load() => _load();

  Future<void> _load() async {
    _settings = await _controller.loadSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String locale) async {
    _settings = _settings.copyWith(language: locale);
    await _controller.saveSetting('language', locale);
    notifyListeners();
  }

  Future<void> setConfidenceThreshold(double threshold) async {
    _settings = _settings.copyWith(confidenceThreshold: threshold);
    await _controller.saveSetting('confidence_threshold', threshold.toString());
    notifyListeners();
  }

  Future<bool> clearCache() => _controller.clearCache();
}
