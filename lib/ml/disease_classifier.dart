
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_error.dart';
import '../core/utils/logger.dart';

class ClassificationResult {
  final String diseaseName;
  final double confidence;
  final int    classIndex;

  const ClassificationResult({
    required this.diseaseName,
    required this.confidence,
    required this.classIndex,
  });

  bool get isUnknown => diseaseName == 'Unknown';
}

class DiseaseClassifier {
  Interpreter? _interpreter;

  bool get isModelLoaded => _interpreter != null;

  Future<bool> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.modelAssetPath);
      AppLogger.info(
        'Model loaded: ${AppConstants.modelAssetPath}',
        'DiseaseClassifier',
      );
      return true;
    } catch (e) {
      AppLogger.error('Model load failed', 'DiseaseClassifier', e);
      throw AppError(
        code: AppErrorCode.modelLoadFailed,
        message: 'Failed to load inference model.',
        originalError: e,
      );
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }


  ClassificationResult classify(Float32List inputTensor) {
    if (_interpreter == null) {
      throw AppError(
        code: AppErrorCode.modelLoadFailed,
        message: 'Model not loaded. Call loadModel() first.',
      );
    }

    try {
      final input = inputTensor.reshape([
        1,
        AppConstants.modelInputSize,
        AppConstants.modelInputSize,
        3,
      ]);

      final output = List.generate(
        1,
        (_) => List.filled(AppConstants.numDiseaseClasses, 0.0),
      );

      _interpreter!.run(input, output);

      final scores    = output[0];
      final maxScore  = scores.reduce((a, b) => a > b ? a : b);
      final maxIndex  = scores.indexOf(maxScore);

      final diseaseName = maxScore >= AppConstants.confidenceThreshold
          ? AppConstants.diseaseClassNames[maxIndex]
          : 'Unknown';

      AppLogger.info(
        'Inference: $diseaseName (${(maxScore * 100).toStringAsFixed(1)}%)',
        'DiseaseClassifier',
      );

      return ClassificationResult(
        diseaseName: diseaseName,
        confidence:  maxScore,
        classIndex:  maxIndex,
      );
    } catch (e) {
      if (e is AppError) rethrow;
      AppLogger.error('Inference failed', 'DiseaseClassifier', e);
      throw AppError(
        code: AppErrorCode.inferenceFailed,
        message: 'Model inference crashed.',
        originalError: e,
      );
    }
  }

  List<ClassificationResult> getTopPredictions(
    Float32List inputTensor, {
    int topN = 3,
  }) {
    final result = classify(inputTensor);
    return [result];
  }
}
