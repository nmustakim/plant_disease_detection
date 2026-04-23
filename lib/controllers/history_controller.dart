

import '../data/database/database_manager.dart';
import '../data/database/daos/predictions_dao.dart';
import '../data/models/prediction.dart';
import '../core/utils/logger.dart';

class HistoryController {
  final DatabaseManager database;
  late final PredictionsDao _dao = PredictionsDao(database);

  HistoryController({required this.database});

  Future<List<Prediction>> loadPredictions() async {
    AppLogger.info('Loading prediction history', 'HistoryController');
    return _dao.getAll();
  }

  Future<Prediction?> getPrediction(String id) => _dao.getById(id);

  Future<bool> deletePrediction(String id) async {
    final rows = await _dao.delete(id);
    AppLogger.info('Deleted prediction $id', 'HistoryController');
    return rows > 0;
  }

  Future<void> clearAll() async {
    await _dao.deleteAll();
    AppLogger.info('Cleared all predictions', 'HistoryController');
  }
}
