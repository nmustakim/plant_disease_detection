import 'package:flutter/foundation.dart';
import '../controllers/settings_controller.dart';
import '../core/constants/app_constants.dart';
import '../ml/disease_classifier.dart';
import '../services/translation/translation_service.dart';

enum SettingsLoadState { idle, loading, loaded, error }

enum ModelUpdateState {
  idle,
  checking,
  updateAvailable,
  downloading,
  upToDate,
  error,
}

class SettingsProvider extends ChangeNotifier {
  final SettingsController _controller;
  final DiseaseClassifier _classifier;


  SettingsLoadState _loadState = SettingsLoadState.idle;
  String? _errorMessage;


  String _language = AppConstants.languageEnglish;
  String _modelVersion = AppConstants.appVersion;
  double _confidenceThreshold = AppConstants.confidenceThreshold;
  int _lastSync = 0;


  bool _isClearingCache = false;


  ModelUpdateState _modelUpdateState = ModelUpdateState.idle;
  String? _pendingUpdateVersion;
  String? _modelUpdateError;


  SettingsProvider(
      this._controller, {
        DiseaseClassifier? classifier,
      }) : _classifier = classifier ?? DiseaseClassifier();


  SettingsLoadState get loadState => _loadState;
  String? get errorMessage => _errorMessage;
  bool get isLoaded => _loadState == SettingsLoadState.loaded;

  String get language => _language;
  String get modelVersion => _modelVersion;
  double get confidenceThreshold => _confidenceThreshold;
  int get lastSync => _lastSync;

  bool get isClearingCache => _isClearingCache;

  ModelUpdateState get modelUpdateState => _modelUpdateState;
  String? get pendingUpdateVersion => _pendingUpdateVersion;
  String? get modelUpdateError => _modelUpdateError;

  String get languageDisplayName =>
      _language == AppConstants.languageBengali ? 'বাংলা (Bengali)' : 'English';

  Future<void> loadSettings() async {
    if (_loadState == SettingsLoadState.loading) return;

    _loadState = SettingsLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _language = await _controller.getLanguage();
      _modelVersion = await _controller.getModelVersion();
      _confidenceThreshold = await _controller.getConfidenceThreshold();
      _lastSync = await _controller.getLastSync();
      _loadState = SettingsLoadState.loaded;
    } catch (e, st) {
      debugPrint('[SettingsProvider] loadSettings error: $e\n$st');
      _errorMessage = e.toString();
      _loadState = SettingsLoadState.error;
    }

    notifyListeners();
  }


  Future<bool> setLanguage(String code) async {
    if (code == _language) return true;

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

    try {
      final success = await _controller.clearCache();
      return success;
    } finally {
      _isClearingCache = false;
      notifyListeners();
    }
  }


  Future<void> checkForModelUpdate() async {
    if (_modelUpdateState == ModelUpdateState.checking ||
        _modelUpdateState == ModelUpdateState.downloading) {
      return;
    }

    _modelUpdateState = ModelUpdateState.checking;
    _modelUpdateError = null;
    _pendingUpdateVersion = null;
    notifyListeners();

    try {
      final result = await _controller.checkForModelUpdate();

      if (!result.updateAvailable) {
        _modelUpdateState = ModelUpdateState.upToDate;
        notifyListeners();
        return;
      }

      _pendingUpdateVersion = result.newVersion;
      _modelUpdateState = ModelUpdateState.downloading;
      notifyListeners();

      final localPath = await _controller.downloadModelUpdate(
        downloadUrl: result.downloadUrl!,
        newVersion: result.newVersion!,
      );

      if (localPath != null) {
        await _classifier.loadModelFromFile(localPath);
        _modelVersion = result.newVersion!;
        _modelUpdateState = ModelUpdateState.idle;
      } else {
        _modelUpdateError = 'model_download_failed'.tr;
        _modelUpdateState = ModelUpdateState.error;
      }
    } catch (e, st) {
      debugPrint('[SettingsProvider] checkForModelUpdate error: $e\n$st');
      _modelUpdateError = 'model_update_error'.tr;
      _modelUpdateState = ModelUpdateState.error;
    }

    notifyListeners();
  }


  Future<bool> resetAllSettings() async {
    try {
      final success = await _controller.resetAllSettings();
      if (success) {
        await loadSettings();
      }
      return success;
    } catch (e) {
      debugPrint('[SettingsProvider] resetAllSettings error: $e');
      return false;
    }
  }
}