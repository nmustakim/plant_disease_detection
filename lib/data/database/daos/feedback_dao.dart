import 'package:sqflite/sqflite.dart';
import '../../models/feedback.dart';
import '../database_helper.dart';
import '../../../core/utils/logger.dart';


class FeedbackDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> submitFeedback(Feedback feedback) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert(
        'feedback',
        feedback.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.info('Feedback submitted: $id', 'FeedbackDao');
      return id;
    } catch (e) {
      AppLogger.error('Failed to submit feedback', 'FeedbackDao', e);
      rethrow;
    }
  }

  Future<bool> updateFeedback(int feedbackId, Feedback feedback) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'feedback',
        feedback.toMap(),
        where: 'feedback_id = ?',
        whereArgs: [feedbackId],
      );
      AppLogger.info('Feedback updated: $feedbackId', 'FeedbackDao');
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to update feedback', 'FeedbackDao', e);
      rethrow;
    }
  }

  Future<Feedback?> getFeedbackByPredictionId(String predictionId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'feedback',
        where: 'prediction_id = ?',
        whereArgs: [predictionId],
      );

      if (maps.isEmpty) return null;
      return Feedback.fromMap(maps.first);
    } catch (e) {
      AppLogger.error('Failed to get feedback by prediction ID', 'FeedbackDao', e);
      rethrow;
    }
  }

  Future<List<Feedback>> getAllFeedbackForDisease(String diseaseName) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT f.* FROM feedback f
        INNER JOIN predictions p ON f.prediction_id = p.id
        INNER JOIN disease_info d ON p.disease_id = d.disease_id
        WHERE d.disease_name = ?
        ORDER BY f.timestamp DESC
      ''', [diseaseName]);

      return List.generate(maps.length, (i) => Feedback.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get feedback for disease', 'FeedbackDao', e);
      rethrow;
    }
  }

  Future<bool> deleteFeedback(int feedbackId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'feedback',
        where: 'feedback_id = ?',
        whereArgs: [feedbackId],
      );
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to delete feedback', 'FeedbackDao', e);
      rethrow;
    }
  }

  Future<AccuracyStats> getAccuracyMetrics(String diseaseName) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN f.user_feedback = 'Correct' THEN 1 ELSE 0 END) as correct,
          SUM(CASE WHEN f.user_feedback = 'Incorrect' THEN 1 ELSE 0 END) as incorrect,
          SUM(CASE WHEN f.user_feedback = 'Unsure' THEN 1 ELSE 0 END) as unsure
        FROM feedback f
        INNER JOIN predictions p ON f.prediction_id = p.id
        INNER JOIN disease_info d ON p.disease_id = d.disease_id
        WHERE d.disease_name = ?
      ''', [diseaseName]);

      if (result.isEmpty) {
        return AccuracyStats(total: 0, correct: 0, incorrect: 0, unsure: 0);
      }

      final map = result.first;
      return AccuracyStats(
        total: map['total'] as int,
        correct: map['correct'] as int,
        incorrect: map['incorrect'] as int,
        unsure: map['unsure'] as int,
      );
    } catch (e) {
      AppLogger.error('Failed to get accuracy metrics', 'FeedbackDao', e);
      rethrow;
    }
  }




  Future<List<Feedback>> getUnsyncedFeedback() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'feedback',
        where: 'is_synced = 0',
        orderBy: 'timestamp ASC',
      );

      return List.generate(maps.length, (i) => Feedback.fromMap(maps[i]));
    } catch (e) {
      AppLogger.error('Failed to get unsynced feedback', 'FeedbackDao', e);
      return [];
    }
  }

  Future<bool> markAsSynced(int feedbackId) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        'feedback',
        {'is_synced': 1},
        where: 'feedback_id = ?',
        whereArgs: [feedbackId],
      );
      return count > 0;
    } catch (e) {
      AppLogger.error('Failed to mark feedback as synced', 'FeedbackDao', e);
      return false;
    }
  }
}

class AccuracyStats {
  final int total;
  final int correct;
  final int incorrect;
  final int unsure;

  AccuracyStats({
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.unsure,
  });

  double get accuracy {
    if (total == 0) return 0.0;
    return correct / total;
  }

  String get accuracyPercentage {
    return '${(accuracy * 100).toStringAsFixed(1)}%';
  }
}