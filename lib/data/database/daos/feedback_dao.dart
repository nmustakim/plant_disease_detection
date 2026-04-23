// lib/data/database/daos/feedback_dao.dart
// IT402 §4.2.6 – feedback table DAO | UC5

import '../database_manager.dart';
import '../../models/feedback.dart';

class FeedbackDao {
  final DatabaseManager _db;
  FeedbackDao(this._db);

  Future<void> insert(FeedbackModel feedback) async =>
      _db.insert('feedback', feedback.toMap());

  Future<List<FeedbackModel>> getByPredictionId(String predictionId) async {
    final rows = await _db.query('feedback',
        where: 'prediction_id = ?', whereArgs: [predictionId]);
    return rows.map(FeedbackModel.fromMap).toList();
  }

  Future<Map<String, dynamic>> getAccuracyMetrics() async {
    final rows = await _db.rawQuery('''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN user_feedback = 'Correct'   THEN 1 ELSE 0 END) AS correct,
        SUM(CASE WHEN user_feedback = 'Incorrect' THEN 1 ELSE 0 END) AS incorrect,
        SUM(CASE WHEN user_feedback = 'Unsure'    THEN 1 ELSE 0 END) AS unsure
      FROM feedback
    ''');
    return rows.isNotEmpty ? rows.first : {};
  }
}
