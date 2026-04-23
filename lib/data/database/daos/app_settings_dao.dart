// lib/data/database/daos/app_settings_dao.dart (IT402 §4.2.4)
import '../database_manager.dart';

class AppSettingsDao {
  AppSettingsDao(this._db);
  final DatabaseManager _db;

  Future<String?> getValue(String key) async {
    final rows = await _db.query('app_settings', where: 'setting_key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['setting_value'] as String?;
  }

  /// Upserts a setting – inserts if key is new, updates if it already exists.
  Future<void> setValue(String key, String value) async {
    await _db.insert('app_settings', {
      'setting_key':   key,
      'setting_value': value,
      'updated_at':    DateTime.now().millisecondsSinceEpoch,
    }); // DatabaseManager.insert uses ConflictAlgorithm.replace → safe upsert
  }

  Future<Map<String, String>> getAllSettings() async {
    final rows = await _db.query('app_settings');
    return {for (final r in rows) r['setting_key'] as String: r['setting_value'] as String};
  }
}
