import 'package:sqflite/sqflite.dart';
import '../data/database/database_helper.dart';
import '../data/models/app_settings.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../services/file/file_manager.dart';
import '../services/translation/translation_service.dart';
import '../services/sync/firebase_sync_service.dart';

/// Result of a model-update check.
class ModelUpdateResult {
  final bool updateAvailable;
  final String? newVersion;
  final String? downloadUrl;
  final double? sizeMb;

  ModelUpdateResult({
    required this.updateAvailable,
    this.newVersion,
    this.downloadUrl,
    this.sizeMb,
  });
}

class SettingsController {
  final DatabaseHelper _dbHelper;
  final FileManager _fileManager;

  SettingsController({
    DatabaseHelper? dbHelper,
    FileManager? fileManager,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _fileManager = fileManager ?? FileManager();

  Future<String> getSetting(String key, {String defaultValue = ''}) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'app_settings',
        where: 'setting_key = ?',
        whereArgs: [key],
      );
      if (maps.isEmpty) return defaultValue;
      return AppSettings.fromMap(maps.first).settingValue;
    } catch (e) {
      AppLogger.error('Failed to get setting: $key', 'SettingsController', e);
      return defaultValue;
    }
  }

  Future<bool> setSetting(String key, String value) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'app_settings',
        AppSettings(settingKey: key, settingValue: value).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.info('Setting saved: $key = $value', 'SettingsController');
      return true;
    } catch (e) {
      AppLogger.error('Failed to save setting: $key', 'SettingsController', e);
      return false;
    }
  }

  Future<String> getLanguage() async {
    String language = await getSetting(
      AppConstants.settingsLanguage,
      defaultValue: AppConstants.languageEnglish,
    );
    if (language != AppConstants.languageEnglish &&
        language != AppConstants.languageBengali) {
      language = AppConstants.languageEnglish;
    }
    return language;
  }

  Future<bool> setLanguage(String languageCode) async {
    try {
      if (languageCode != AppConstants.languageEnglish &&
          languageCode != AppConstants.languageBengali) {
        AppLogger.error('Invalid language code: $languageCode', 'SettingsController');
        return false;
      }

      final saved = await setSetting(AppConstants.settingsLanguage, languageCode);

      if (saved) {
        await TranslationService.instance.loadLanguage(languageCode);
        AppLogger.info('Language changed to: $languageCode', 'SettingsController');
      }

      return saved;
    } catch (e) {
      AppLogger.error('Failed to set language', 'SettingsController', e);
      return false;
    }
  }

  Future<String> getModelVersion() =>
      getSetting(AppConstants.settingsModelVersion, defaultValue: AppConstants.appVersion);

  Future<bool> setModelVersion(String version) =>
      setSetting(AppConstants.settingsModelVersion, version);

  Future<double> getConfidenceThreshold() async {
    final raw = await getSetting(
      AppConstants.settingsConfidenceThreshold,
      defaultValue: AppConstants.confidenceThreshold.toString(),
    );
    final threshold = double.tryParse(raw) ?? AppConstants.confidenceThreshold;
    return threshold.clamp(0.0, 1.0);
  }

  Future<bool> setConfidenceThreshold(double threshold) async {
    final clampedThreshold = threshold.clamp(0.0, 1.0);
    return setSetting(AppConstants.settingsConfidenceThreshold, clampedThreshold.toString());
  }

  Future<int> getLastSync() async {
    final raw = await getSetting(AppConstants.settingsLastSync, defaultValue: '0');
    return int.tryParse(raw) ?? 0;
  }

  Future<bool> updateLastSync() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return setSetting(AppConstants.settingsLastSync, timestamp.toString());
  }

  Future<bool> clearCache() async {
    try {
      final result = await _fileManager.clearCache();
      if (result) {
        AppLogger.info('Cache cleared successfully', 'SettingsController');
      } else {
        AppLogger.warning('Cache clear returned false', 'SettingsController');
      }
      return result;
    } catch (e) {
      AppLogger.error('Failed to clear cache', 'SettingsController', e);
      return false;
    }
  }

  Future<Map<String, String>> getAllSettings() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('app_settings');
      return {
        for (final m in maps)
          m['setting_key'] as String: m['setting_value'] as String
      };
    } catch (e) {
      AppLogger.error('Failed to load all settings', 'SettingsController', e);
      return {};
    }
  }

  Future<bool> resetAllSettings() async {
    try {
      await setLanguage(AppConstants.languageEnglish);
      await setConfidenceThreshold(AppConstants.confidenceThreshold);
      await setModelVersion(AppConstants.appVersion);
      await updateLastSync();
      AppLogger.info('All settings reset to defaults', 'SettingsController');
      return true;
    } catch (e) {
      AppLogger.error('Failed to reset settings', 'SettingsController', e);
      return false;
    }
  }

  Future<bool> isBengaliMode() async {
    final language = await getLanguage();
    return language == AppConstants.languageBengali;
  }

  Future<String> getLanguageDisplayName() async {
    final language = await getLanguage();
    return language == AppConstants.languageBengali ? 'বাংলা (Bengali)' : 'English';
  }

  /// Check Firebase for a newer model version.
  /// Returns [ModelUpdateResult] describing whether an update is available.
  Future<ModelUpdateResult> checkForModelUpdate() async {
    try {
      final sync = FirebaseSyncService.instance;
      await sync.initialize();

      if (!sync.isAvailable) {
        AppLogger.warning('Firebase unavailable; skipping model update check', 'SettingsController');
        return ModelUpdateResult(updateAvailable: false);
      }

      final remoteData = await sync.checkForModelUpdate();
      if (remoteData == null) {
        return ModelUpdateResult(updateAvailable: false);
      }

      final remoteVersion = remoteData['version'] as String?;
      final localVersion = await getModelVersion();

      if (remoteVersion == null || remoteVersion == localVersion) {
        AppLogger.info('Model is up to date (v$localVersion)', 'SettingsController');
        return ModelUpdateResult(updateAvailable: false);
      }

      AppLogger.info('Model update available: $localVersion → $remoteVersion', 'SettingsController');
      return ModelUpdateResult(
        updateAvailable: true,
        newVersion: remoteVersion,
        downloadUrl: remoteData['download_url'] as String?,
        sizeMb: (remoteData['size_mb'] as num?)?.toDouble(),
      );
    } catch (e) {
      AppLogger.error('checkForModelUpdate failed', 'SettingsController', e);
      return ModelUpdateResult(updateAvailable: false);
    }
  }

  /// Download the model at [downloadUrl], persist [newVersion], and return
  /// the local file path so the caller can reload the interpreter.
  Future<String?> downloadModelUpdate({
    required String downloadUrl,
    required String newVersion,
  }) async {
    try {
      final sync = FirebaseSyncService.instance;
      final localPath = await sync.downloadModel(downloadUrl, newVersion);

      if (localPath != null) {
        await setModelVersion(newVersion);
        AppLogger.info('Model updated to v$newVersion at $localPath', 'SettingsController');
      }

      return localPath;
    } catch (e) {
      AppLogger.error('downloadModelUpdate failed', 'SettingsController', e);
      return null;
    }
  }
}