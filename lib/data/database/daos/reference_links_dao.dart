// lib/data/database/daos/reference_links_dao.dart
// IT402 §4.2.3 – reference_links table DAO

import '../database_manager.dart';
import '../../models/reference_link.dart';

class ReferenceLinksDao {
  final DatabaseManager _db;
  ReferenceLinksDao(this._db);

  Future<void> insert(ReferenceLink link) async =>
      _db.insert('reference_links', link.toMap());

  Future<List<ReferenceLink>> getByDiseaseId(String diseaseId) async {
    final rows = await _db.query('reference_links',
        where: 'disease_id = ?', whereArgs: [diseaseId]);
    return rows.map(ReferenceLink.fromMap).toList();
  }
}
