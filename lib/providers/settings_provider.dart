import 'package:flutter/foundation.dart';
import '../controllers/settings_controller.dart';
import '../core/constants/app_constants.dart';

enum SettingsLoadState { idle, loading, loaded, error }

class SettingsProvider extends ChangeNotifier {
  final SettingsController _controller;

  SettingsLoadState _loadState = SettingsLoadState.idle;
  String _language = AppConstants.languageEnglish;
  String _modelVersion = AppConstants.appVersion;
  double _confidenceThreshold = AppConstants.confidenceThreshold;
  int _lastSync = 0;
  String? _errorMessage;
  bool _isClearingCache = false;

  SettingsProvider(this._controller);

  SettingsLoadState get loadState => _loadState;
  String get language => _language;
  String get modelVersion => _modelVersion;
  double get confidenceThreshold => _confidenceThreshold;
  int get lastSync => _lastSync;
  String? get errorMessage => _errorMessage;
  bool get isClearingCache => _isClearingCache;
  bool get isLoaded => _loadState == SettingsLoadState.loaded;

  String get languageDisplayName =>
      _language == AppConstants.languageBengali ? 'বাংলা (Bengali)' : 'English';

  Future<void> loadSettings() async {
    _loadState = SettingsLoadState.loading;
    notifyListeners();

    try {
      _language = await _controller.getLanguage();
      _modelVersion = await _controller.getModelVersion();
      _confidenceThreshold = await _controller.getConfidenceThreshold();
      _lastSync = await _controller.getLastSync();
      _loadState = SettingsLoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _loadState = SettingsLoadState.error;
    }

    notifyListeners();
  }

  Future<bool> setLanguage(String code) async {
    final success = await _controller.setLanguage(code);
    if (success) {
      _language = code;
      notifyListeners();
    }
    return success;
  }

  Future<bool> setConfidenceThreshold(double threshold) async {
    final success = await _controller.setConfidenceThreshold(threshold);
    if (success) {
      _confidenceThreshold = threshold;
      notifyListeners();
    }
    return success;
  }

  Future<bool> clearCache() async {
    _isClearingCache = true;
    notifyListeners();

    final success = await _controller.clearCache();

    _isClearingCache = false;
    notifyListeners();
    return success;
  }
}