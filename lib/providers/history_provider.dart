

import 'package:flutter/foundation.dart';
import '../controllers/history_controller.dart';
import '../data/models/prediction.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryController _controller;

  List<Prediction> _predictions = [];
  bool             isLoading    = false;

  List<Prediction> get predictions => _predictions;

  HistoryProvider(this._controller);

  Future<void> loadPredictions() async {
    isLoading = true;
    notifyListeners();
    _predictions = await _controller.loadPredictions();
    isLoading    = false;
    notifyListeners();
  }

  Future<void> deletePrediction(String id) async {
    await _controller.deletePrediction(id);
    _predictions.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _controller.clearAll();
    _predictions = [];
    notifyListeners();
  }
}
