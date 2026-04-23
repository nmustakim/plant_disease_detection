import 'package:sqflite/sqflite.dart';
import '../../models/prediction.dart';
import '../database_helper.dart';
import '../../../core/utils/logger.dart';


class PredictionsDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<String> insert(Prediction prediction) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'predictions',
        prediction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.info('Prediction inserted: ${prediction.id}', 'PredictionsDao');
      return prediction.id;
    } catch (e) {
      AppLogger.error('Failed to insert prediction', 'PredictionsDao', e);
      rethrow;
    }
  }

  Future<List<Prediction>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          p.*,
          d.disease_name
        FROM predictions p
        LEFT JOIN disease_info d ON p.disease_id = d.disease_id
        ORDER BY p.timestamp DESC
      ''');

      return List.generate(maps.length, (i) => Prediction.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get all predictions', 'PredictionsDao', e);
      rethrow;
    }
  }

  Future<Prediction?> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          p.*,
          d.disease_name
        FROM predictions p
        LEFT JOIN disease_info d ON p.disease_id = d.disease_id
        WHERE p.id = ?
      ''', [id]);

      if (maps.isEmpty) return null;
      return Prediction.fromMap(maps.first);
    } catch (e) {
      AppLogger.error('Failed to get prediction by ID', 'PredictionsDao', e);
      rethrow;
    }
  }

  Future<List<Prediction>> getByDiseaseId(String diseaseId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          p.*,
          d.disease_name
        FROM predictions p
        LEFT JOIN disease_info d ON p.disease_id = d.disease_id
        WHERE p.disease_id = ?
        ORDER BY p.timestamp DESC
      ''', [diseaseId]);

      return List.generate(maps.length, (i) => Prediction.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get predictions by disease ID', 'PredictionsDao', e);
      rethrow;
    }
  }

  Future<List<Prediction>> getRecent(int limit) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          p.*,
          d.disease_name
        FROM predictions p
        LEFT JOIN disease_info d ON p.disease_id = d.disease_id
        ORDER BY p.timestamp DESC
        LIMIT ?
      ''', [limit]);

      return List.generate(maps.length, (i) => Prediction.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get recent predictions', 'PredictionsDao', e);
      rethrow;
    }
  }

  Future<bool> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'predictions',
        where: 'id = ?',
        whereArgs: [id],
      );
      AppLogger.info('Prediction deleted: $id', 'PredictionsDao');
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to delete prediction', 'PredictionsDao', e);
      rethrow;
    }
  }

  /// Delete all predictions
  Future<int> deleteAll() async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete('predictions');
      AppLogger.info('All predictions deleted: $count records', 'PredictionsDao');
      return count;
    } catch (e) {
      AppLogger.error('Failed to delete all predictions', 'PredictionsDao', e);
      rethrow;
    }
  }

  Future<int> getCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM predictions');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      AppLogger.error('Failed to get prediction count', 'PredictionsDao', e);
      rethrow;
    }
  }
}