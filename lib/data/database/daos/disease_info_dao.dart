import 'package:sqflite/sqflite.dart';
import '../../models/disease_info.dart';
import '../database_helper.dart';
import '../../../core/utils/logger.dart';

class DiseaseInfoDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<String> insert(DiseaseInfo diseaseInfo) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'disease_info',
        diseaseInfo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.info('Disease info inserted: ${diseaseInfo.diseaseId}', 'DiseaseInfoDao');
      return diseaseInfo.diseaseId;
    } catch (e) {
      AppLogger.error('Failed to insert disease info', 'DiseaseInfoDao', e);
      rethrow;
    }
  }

  Future<List<DiseaseInfo>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'disease_info',
        orderBy: 'disease_name ASC',
      );

      return List.generate(maps.length, (i) => DiseaseInfo.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get all disease info', 'DiseaseInfoDao', e);
      rethrow;
    }
  }

  Future<DiseaseInfo?> getById(String diseaseId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'disease_info',
        where: 'disease_id = ?',
        whereArgs: [diseaseId],
      );

      if (maps.isEmpty) return null;
      return DiseaseInfo.fromMap(maps.first);
    } catch (e) {
      AppLogger.error('Failed to get disease info by ID', 'DiseaseInfoDao', e);
      rethrow;
    }
  }

  Future<DiseaseInfo?> getByName(String diseaseName) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'disease_info',
        where: 'disease_name = ?',
        whereArgs: [diseaseName],
      );

      if (maps.isEmpty) return null;
      return DiseaseInfo.fromMap(maps.first);
    } catch (e) {
      AppLogger.error('Failed to get disease info by name', 'DiseaseInfoDao', e);
      rethrow;
    }
  }

  Future<bool> update(DiseaseInfo diseaseInfo) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'disease_info',
        diseaseInfo.toMap(),
        where: 'disease_id = ?',
        whereArgs: [diseaseInfo.diseaseId],
      );
      AppLogger.info('Disease info updated: ${diseaseInfo.diseaseId}', 'DiseaseInfoDao');
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to update disease info', 'DiseaseInfoDao', e);
      rethrow;
    }
  }

  Future<bool> delete(String diseaseId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'disease_info',
        where: 'disease_id = ?',
        whereArgs: [diseaseId],
      );
      AppLogger.info('Disease info deleted: $diseaseId', 'DiseaseInfoDao');
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to delete disease info', 'DiseaseInfoDao', e);
      rethrow;
    }
  }
}