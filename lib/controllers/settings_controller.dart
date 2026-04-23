
import '../data/database/database_manager.dart';
import '../data/models/app_settings.dart';
import '../services/file/file_manager.dart';
import '../core/utils/logger.dart';

class SettingsController {
  final DatabaseManager database;
  final FileManager     _files = FileManager();

  SettingsController({required this.database});

  Future<AppSettings> loadSettings() async {
    final rows = await database.query('app_settings');
    if (rows.isEmpty) return const AppSettings();
    final map = {for (final r in rows) r['setting_key'] as String: r['setting_value'] as String};
    return AppSettings.fromRows(map);
  }

  Future<void> saveSetting(String key, String value) async {
    await database.insert('app_settings', {
      'setting_key':   key,
      'setting_value': value,
      'updated_at':    DateTime.now().millisecondsSinceEpoch,
    });
    AppLogger.info('Setting saved: $key=$value', 'SettingsController');
  }

  Future<void> saveSettings(AppSettings settings) async {
    for (final entry in settings.toSettingsRows().entries) {
      await saveSetting(entry.key, entry.value);
    }
  }

  Future<bool> clearCache() => _files.clearCache();

  Future<int> clearOldImages({int daysOld = 30}) =>
      _files.deleteOldImages(daysOld);
}
