import '../../models/reference_link.dart';
import '../database_helper.dart';
import '../../../core/utils/logger.dart';

class ReferenceLinksDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(ReferenceLink link) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('reference_links', link.toMap());
      AppLogger.info('Reference link inserted: $id', 'ReferenceLinksDao');
      return id;
    } catch (e) {
      AppLogger.error('Failed to insert reference link', 'ReferenceLinksDao', e);
      rethrow;
    }
  }

  Future<List<ReferenceLink>> getByDiseaseId(String diseaseId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reference_links',
        where: 'disease_id = ?',
        whereArgs: [diseaseId],
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) => ReferenceLink.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get reference links', 'ReferenceLinksDao', e);
      rethrow;
    }
  }

  Future<bool> delete(int linkId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'reference_links',
        where: 'link_id = ?',
        whereArgs: [linkId],
      );
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to delete reference link', 'ReferenceLinksDao', e);
      rethrow;
    }
  }
}