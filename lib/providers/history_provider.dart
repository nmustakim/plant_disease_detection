import 'package:flutter/foundation.dart';
import '../data/database/database_manager.dart';
import '../data/models/prediction.dart';

enum HistoryState {
  idle,
  loading,
  loaded,
  error,
}


class HistoryProvider extends ChangeNotifier {
  final DatabaseManager _database;

  HistoryState _state = HistoryState.idle;
  List<Prediction> _predictions = [];
  String? _errorMessage;

  HistoryProvider(this._database);

  HistoryState get state => _state;
  List<Prediction> get predictions => _predictions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == HistoryState.loading;
  bool get hasError => _state == HistoryState.error;
  bool get isEmpty => _predictions.isEmpty && _state == HistoryState.loaded;

  Future<void> loadHistory() async {
    try {
      _setState(HistoryState.loading);
      _errorMessage = null;

      _predictions = await _database.getAllPredictions();
      _setState(HistoryState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(HistoryState.error);
    }
  }

  Future<bool> deletePrediction(String id) async {
    try {
      final success = await _database.deletePrediction(id);
      if (success) {
        _predictions.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> deleteAllPredictions() async {
    try {
      final success = await _database.deleteAllPredictions();
      if (success) {
        _predictions.clear();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Prediction? getPredictionById(String id) {
    try {
      return _predictions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }

  void _setState(HistoryState newState) {
    _state = newState;
    notifyListeners();
  }
}