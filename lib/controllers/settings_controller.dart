import 'package:sqflite/sqflite.dart';
import '../data/database/database_helper.dart';
import '../data/models/app_settings.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../services/file/file_manager.dart';

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

  /// Save / update a setting.
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


  Future<String> getLanguage() =>
      getSetting(AppConstants.settingsLanguage, defaultValue: AppConstants.languageEnglish);

  Future<bool> setLanguage(String languageCode) =>
      setSetting(AppConstants.settingsLanguage, languageCode);

  Future<String> getModelVersion() =>
      getSetting(AppConstants.settingsModelVersion, defaultValue: AppConstants.appVersion);

  Future<bool> setModelVersion(String version) =>
      setSetting(AppConstants.settingsModelVersion, version);

  Future<double> getConfidenceThreshold() async {
    final raw = await getSetting(
      AppConstants.settingsConfidenceThreshold,
      defaultValue: AppConstants.confidenceThreshold.toString(),
    );
    return double.tryParse(raw) ?? AppConstants.confidenceThreshold;
  }

  Future<bool> setConfidenceThreshold(double threshold) =>
      setSetting(AppConstants.settingsConfidenceThreshold, threshold.toString());

  Future<int> getLastSync() async {
    final raw = await getSetting(AppConstants.settingsLastSync, defaultValue: '0');
    return int.tryParse(raw) ?? 0;
  }

  Future<bool> updateLastSync() =>
      setSetting(AppConstants.settingsLastSync,
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString());


  Future<bool> clearCache() async {
    try {
      final result = await _fileManager.clearCache();
      AppLogger.info('Cache cleared: $result', 'SettingsController');
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
      return {for (final m in maps) m['setting_key'] as String: m['setting_value'] as String};
    } catch (e) {
      AppLogger.error('Failed to load all settings', 'SettingsController', e);
      return {};
    }
  }
}