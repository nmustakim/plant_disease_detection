

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../controllers/prediction_controller.dart';

enum PredictionState { idle, loading, success, error }

class PredictionProvider extends ChangeNotifier {
  final PredictionController _controller;

  PredictionState   state        = PredictionState.idle;
  PredictionResult? latestResult;
  String?           errorMessage;

  PredictionProvider(this._controller);

  bool get isProcessing => state == PredictionState.loading;


  Future<void> captureFromCamera() async {
    _setLoading();
    try {
      final file = await _controller.startCapture();
      await _runInference(file);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> uploadFromGallery() async {
    _setLoading();
    try {
      final file = await _controller.startGalleryUpload();
      await _runInference(file);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _runInference(File file) async {
    try {
      latestResult = await _controller.runInference(file);
      state        = PredictionState.success;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void reset() {
    state        = PredictionState.idle;
    latestResult = null;
    errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    state        = PredictionState.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    state        = PredictionState.error;
    errorMessage = msg;
    notifyListeners();
  }
}
