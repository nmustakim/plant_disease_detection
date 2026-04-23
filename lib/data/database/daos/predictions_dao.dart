// lib/data/database/daos/predictions_dao.dart
// IT402 §3.3 – PredictionsDAO | implements IT402 §5.3.2 queries

import '../database_manager.dart';
import '../../models/prediction.dart';

class PredictionsDao {
  final DatabaseManager _db;
  PredictionsDao(this._db);

  /// Save a new prediction – IT402 §5.3.1 step 7
  Future<String> insert(Prediction prediction) async {
    await _db.insert('predictions', prediction.toMap());
    return prediction.id;
  }

  /// IT402 §5.3.2 Query 1 – LEFT JOIN so Unknown predictions still appear.
  /// COALESCE falls back to p.disease_id when no disease_info row exists.
  Future<List<Prediction>> getAll() async {
    final rows = await _db.rawQuery('''
      SELECT p.id, p.disease_id, p.confidence, p.timestamp,
             p.image_path, p.model_version, p.device_id,
             COALESCE(d.disease_name, p.disease_id) AS disease_name
      FROM predictions p
      LEFT JOIN disease_info d ON p.disease_id = d.disease_id
      ORDER BY p.timestamp DESC
    ''');
    return rows.map(Prediction.fromMap).toList();
  }

  Future<Prediction?> getById(String id) async {
    final rows = await _db.rawQuery('''
      SELECT p.*,
             COALESCE(d.disease_name, p.disease_id) AS disease_name
      FROM predictions p
      LEFT JOIN disease_info d ON p.disease_id = d.disease_id
      WHERE p.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return Prediction.fromMap(rows.first);
  }

  Future<int> delete(String id) async =>
      _db.delete('predictions', where: 'id = ?', whereArgs: [id]);

  Future<int> deleteAll() async =>
      _db.delete('predictions', where: '1', whereArgs: []);

  /// IT402 §5.3.2 Query 2 – accuracy stats per disease
  Future<List<Map<String, dynamic>>> getAccuracyStats() async {
    return _db.rawQuery('''
      SELECT p.disease_id,
             COUNT(*) AS total_predictions,
             SUM(CASE WHEN f.user_feedback = 'Correct' THEN 1 ELSE 0 END) AS correct_count,
             AVG(p.confidence) AS avg_confidence,
             ROUND(100.0 *
               SUM(CASE WHEN f.user_feedback = 'Correct' THEN 1 ELSE 0 END)
               / COUNT(*), 2) AS accuracy_pct
      FROM predictions p
      LEFT JOIN feedback f ON p.id = f.prediction_id
      GROUP BY p.disease_id
      ORDER BY total_predictions DESC
    ''');
  }
}
