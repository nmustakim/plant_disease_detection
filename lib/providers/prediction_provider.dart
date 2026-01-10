import 'package:flutter/foundation.dart';
import 'dart:io';
import '../controllers/prediction_controller.dart';
import '../data/models/prediction.dart';
import '../data/models/disease_info.dart';

enum PredictionState {
  idle,
  capturingImage,
  selectingImage,
  preprocessing,
  classifying,
  saving,
  success,
  error,
}


class PredictionProvider extends ChangeNotifier {
  final PredictionController _controller;

  PredictionState _state = PredictionState.idle;
  Prediction? _currentPrediction;
  DiseaseInfo? _currentDiseaseInfo;
  String? _errorMessage;
  File? _selectedImage;

  PredictionProvider(this._controller);

  PredictionState get state => _state;
  Prediction? get currentPrediction => _currentPrediction;
  DiseaseInfo? get currentDiseaseInfo => _currentDiseaseInfo;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;

  bool get isLoading => _state == PredictionState.capturingImage ||
      _state == PredictionState.selectingImage ||
      _state == PredictionState.preprocessing ||
      _state == PredictionState.classifying ||
      _state == PredictionState.saving;

  bool get hasError => _state == PredictionState.error;
  bool get hasResult => _state == PredictionState.success && _currentPrediction != null;

  Future<void> captureAndClassify() async {
    try {
      _setState(PredictionState.capturingImage);
      _errorMessage = null;

      final result = await _controller.captureAndClassify();

      if (result.success) {
        _currentPrediction = result.prediction;
        _currentDiseaseInfo = result.diseaseInfo;
        _selectedImage = File(result.prediction.imagePath);
        _setState(PredictionState.success);
      } else {
        _errorMessage = result.errorMessage ?? 'Failed to classify image';
        _setState(PredictionState.error);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(PredictionState.error);
    }
  }

  Future<void> uploadAndClassify() async {
    try {
      _setState(PredictionState.selectingImage);
      _errorMessage = null;

      final result = await _controller.uploadAndClassify();

      if (result.success) {
        _currentPrediction = result.prediction;
        _currentDiseaseInfo = result.diseaseInfo;
        _selectedImage = File(result.prediction.imagePath);
        _setState(PredictionState.success);
      } else {
        _errorMessage = result.errorMessage ?? 'Failed to classify image';
        _setState(PredictionState.error);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(PredictionState.error);
    }
  }

  void reset() {
    _state = PredictionState.idle;
    _currentPrediction = null;
    _currentDiseaseInfo = null;
    _errorMessage = null;
    _selectedImage = null;
    notifyListeners();
  }

  void _setState(PredictionState newState) {
    _state = newState;
    notifyListeners();
  }
}