import 'package:flutter/foundation.dart';
import '../controllers/settings_controller.dart';
import '../core/constants/app_constants.dart';
import '../ml/disease_classifier.dart';

enum SettingsLoadState { idle, loading, loaded, error }

enum ModelUpdateState { idle, checking, updateAvailable, downloading, upToDate, error }

class SettingsProvider extends ChangeNotifier {
  final SettingsController _controller;
  final DiseaseClassifier _classifier;

  SettingsLoadState _loadState = SettingsLoadState.idle;
  String _language = AppConstants.languageEnglish;
  String _modelVersion = AppConstants.appVersion;
  double _confidenceThreshold = AppConstants.confidenceThreshold;
  int _lastSync = 0;
  String? _errorMessage;
  bool _isClearingCache = false;

  ModelUpdateState _modelUpdateState = ModelUpdateState.idle;
  String? _pendingUpdateVersion;
  String? _modelUpdateError;

  SettingsProvider(this._controller, {DiseaseClassifier? classifier})
      : _classifier = classifier ?? DiseaseClassifier();

  SettingsLoadState get loadState => _loadState;
  String get language => _language;
  String get modelVersion => _modelVersion;
  double get confidenceThreshold => _confidenceThreshold;
  int get lastSync => _lastSync;
  String? get errorMessage => _errorMessage;
  bool get isClearingCache => _isClearingCache;
  bool get isLoaded => _loadState == SettingsLoadState.loaded;

  ModelUpdateState get modelUpdateState => _modelUpdateState;
  String? get pendingUpdateVersion => _pendingUpdateVersion;
  String? get modelUpdateError => _modelUpdateError;

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

  /// Check Firebase for a newer model version. Updates [modelUpdateState]
  /// and, if an update is found, automatically triggers download + reload.
  Future<void> checkForModelUpdate() async {
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
      _modelUpdateState = ModelUpdateState.updateAvailable;
      notifyListeners();

      // Proceed directly to download
      _modelUpdateState = ModelUpdateState.downloading;
      notifyListeners();

      final localPath = await _controller.downloadModelUpdate(
        downloadUrl: result.downloadUrl!,
        newVersion: result.newVersion!,
      );

      if (localPath != null) {
        // Reload the live TFLite interpreter with the new file
        await _classifier.loadModelFromFile(localPath);
        _modelVersion = result.newVersion!;
        _modelUpdateState = ModelUpdateState.idle;
      } else {
        _modelUpdateError = 'Download failed. Please try again.';
        _modelUpdateState = ModelUpdateState.error;
      }
    } catch (e) {
      _modelUpdateError = 'Update failed: ${e.toString()}';
      _modelUpdateState = ModelUpdateState.error;
    }

    notifyListeners();
  }
}