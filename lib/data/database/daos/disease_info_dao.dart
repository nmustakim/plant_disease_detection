
import '../database_manager.dart';
import '../../models/disease_info.dart';

class DiseaseInfoDao {
  final DatabaseManager _db;
  DiseaseInfoDao(this._db);

  /// IT402 §5.3.2 Query 3 – fetch disease with all reference links
  Future<DiseaseInfo?> getByName(String diseaseName) async {
    final rows = await _db.rawQuery('''
      SELECT d.*,
             GROUP_CONCAT(r.link_url,   '|') AS links,
             GROUP_CONCAT(r.link_title, '|') AS titles
      FROM disease_info d
      LEFT JOIN reference_links r ON d.disease_id = r.disease_id
      WHERE d.disease_name = ?
      GROUP BY d.disease_id
    ''', [diseaseName]);
    if (rows.isEmpty) return null;
    return DiseaseInfo.fromMap(rows.first);
  }

  Future<DiseaseInfo?> getById(String diseaseId) async {
    final rows = await _db.rawQuery('''
      SELECT d.*,
             GROUP_CONCAT(r.link_url, '|') AS links
      FROM disease_info d
      LEFT JOIN reference_links r ON d.disease_id = r.disease_id
      WHERE d.disease_id = ?
      GROUP BY d.disease_id
    ''', [diseaseId]);
    if (rows.isEmpty) return null;
    return DiseaseInfo.fromMap(rows.first);
  }

  Future<void> upsert(DiseaseInfo info) async =>
      _db.insert('disease_info', info.toMap());
}
