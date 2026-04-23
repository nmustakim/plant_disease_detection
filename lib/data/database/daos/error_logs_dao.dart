import '../../models/error_log.dart';
import '../database_helper.dart';
import '../../../core/utils/logger.dart';

class ErrorLogsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(ErrorLog errorLog) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('error_logs', errorLog.toMap());
      return id;
    } catch (e) {
      AppLogger.error('Failed to insert error log', 'ErrorLogsDao', e);
      rethrow;
    }
  }

  Future<List<ErrorLog>> getAll({int? limit}) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'error_logs',
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) => ErrorLog.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get error logs', 'ErrorLogsDao', e);
      rethrow;
    }
  }

  Future<bool> markResolved(int errorId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'error_logs',
        {'resolved': 1},
        where: 'error_id = ?',
        whereArgs: [errorId],
      );
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to mark error as resolved', 'ErrorLogsDao', e);
      rethrow;
    }
  }

  Future<int> deleteOld(int daysOld) async {
    try {
      final db = await _dbHelper.database;
      final cutoffTimestamp = DateTime.now()
          .subtract(Duration(days: daysOld))
          .millisecondsSinceEpoch ~/ 1000;

      final count = await db.delete(
        'error_logs',
        where: 'timestamp < ?',
        whereArgs: [cutoffTimestamp],
      );
      return count;
    } catch (e) {
      AppLogger.error('Failed to delete old error logs', 'ErrorLogsDao', e);
      rethrow;
    }
  }
}