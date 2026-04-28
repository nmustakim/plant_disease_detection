import '../data/database/database_manager.dart';
import '../data/models/prediction.dart';
import '../core/utils/logger.dart';

class HistoryController {
  final DatabaseManager database;

  HistoryController({required this.database});


  /// Returns all predictions sorted by timestamp descending (newest first).
  Future<List<Prediction>> getAllPredictions() async {
    try {
      AppLogger.info('Fetching all predictions', 'HistoryController');
      final predictions = await database.getAllPredictions();
      AppLogger.info(
        'Fetched ${predictions.length} prediction(s)',
        'HistoryController',
      );
      return predictions;
    } catch (e, stack) {
      AppLogger.error('Failed to fetch predictions', 'HistoryController', e, stack);
      rethrow;
    }
  }

  /// Returns a single prediction by [id], or `null` if not found.
  Future<Prediction?> getPredictionById(String id) async {
    try {
      return await database.getPredictionById(id);
    } catch (e, stack) {
      AppLogger.error('Failed to fetch prediction $id', 'HistoryController', e, stack);
      rethrow;
    }
  }

/// Deletes the prediction with the given [id].
  /// Returns `true` if the record was deleted, `false` otherwise.
  Future<bool> deletePrediction(String id) async {
    try {
      AppLogger.info('Deleting prediction: $id', 'HistoryController');
      final success = await database.deletePrediction(id);
      AppLogger.info(
        success ? 'Prediction deleted: $id' : 'Prediction not found: $id',
        'HistoryController',
      );
      return success;
    } catch (e, stack) {
      AppLogger.error('Failed to delete prediction $id', 'HistoryController', e, stack);
      return false;
    }
  }

  /// Deletes all prediction records.
  /// Returns `true` if at least one record was deleted.
  Future<bool> deleteAllPredictions() async {
    try {
      AppLogger.info('Deleting all predictions', 'HistoryController');
      final success = await database.deleteAllPredictions();
      AppLogger.info(
        success ? 'All predictions deleted' : 'No predictions to delete',
        'HistoryController',
      );
      return success;
    } catch (e, stack) {
      AppLogger.error('Failed to delete all predictions', 'HistoryController', e, stack);
      return false;
    }
  }
}