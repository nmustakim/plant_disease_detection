import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/error_codes.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';

/// Holds the result of a single classification pass
class ClassificationResult {
  final String className;
  final int classIndex;
  final double confidence;

  ClassificationResult({
    required this.className,
    required this.classIndex,
    required this.confidence,
  });

  bool get isHighConfidence =>
      confidence >= AppConstants.highConfidenceThreshold;

  bool get isMediumConfidence =>
      confidence >= AppConstants.mediumConfidenceThreshold &&
          confidence < AppConstants.highConfidenceThreshold;

  bool get isLowConfidence =>
      confidence < AppConstants.mediumConfidenceThreshold;

  @override
  String toString() =>
      'ClassificationResult(class: $className, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// TFLite float32 disease classifier
class DiseaseClassifier {
  Interpreter? _interpreter;

  final String modelPath;
  final List<String> classNames;
  final double confidenceThreshold;

  DiseaseClassifier({
    this.modelPath = AppConstants.modelAssetPath,
    this.classNames = AppConstants.diseaseClasses,
    this.confidenceThreshold = AppConstants.confidenceThreshold,
  });


  Future<void> loadModel() async {
    try {
      AppLogger.info('Loading model: $modelPath', 'DiseaseClassifier');

      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false;

      _interpreter = await Interpreter.fromAsset(modelPath, options: options);

      final inputTensor  = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      AppLogger.info(
        'Class count: model=${outputTensor.shape[1]}, list=${classNames.length}',
        'DiseaseClassifier',
      );

      // Warn loudly if counts don't match — don't hard-crash in production
      if (outputTensor.shape[1] != classNames.length) {
        AppLogger.warning(
          'MISMATCH — model outputs ${outputTensor.shape[1]} classes '
              'but classNames has ${classNames.length} entries. '
              'Predictions beyond index ${classNames.length - 1} will be labelled Unknown.',
          'DiseaseClassifier',
        );
      }

      AppLogger.info('Model loaded successfully', 'DiseaseClassifier');
      AppLogger.info('Input  → ${inputTensor.shape} ${inputTensor.type}',  'DiseaseClassifier');
      AppLogger.info('Output → ${outputTensor.shape} ${outputTensor.type}', 'DiseaseClassifier');
    } catch (e, stack) {
      AppLogger.error('Model load failed', 'DiseaseClassifier', e);
      if (kDebugMode) print(stack);
      throw ModelException(
        ErrorCodes.errorMessages[ErrorCodes.modelLoadFailed]!,
        ErrorCodes.modelLoadFailed,
      );
    }
  }

  bool isModelLoaded() => _interpreter != null;

  /// Reload the interpreter from a downloaded .tflite file path.
  /// Called after a successful model update download.
  Future<void> loadModelFromFile(String filePath) async {
    try {
      AppLogger.info('Loading model from file: $filePath', 'DiseaseClassifier');

      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false;

      final newInterpreter = Interpreter.fromFile(
        File(filePath),
        options: options,
      );

      // Close old interpreter before replacing
      _interpreter?.close();
      _interpreter = newInterpreter;

      AppLogger.info('Model reloaded from file successfully', 'DiseaseClassifier');
    } catch (e, stack) {
      AppLogger.error('Model reload from file failed', 'DiseaseClassifier', e);
      if (kDebugMode) print(stack);
      throw ModelException(
        ErrorCodes.errorMessages[ErrorCodes.modelLoadFailed]!,
        ErrorCodes.modelLoadFailed,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Inference
  // ---------------------------------------------------------------------------

  /// Accepts a Float32List of shape [224 * 224 * 3] normalised to [0.0, 1.0].
  /// Returns a list of confidence scores, one per class.
  Future<List<double>> runInference(Float32List inputBuffer) async {
    if (!isModelLoaded()) {
      throw ModelException('Model not loaded', ErrorCodes.modelNotFound);
    }

    try {
      // Reshape flat float32 buffer → [1, 224, 224, 3]
      final input = inputBuffer.reshape([1, 224, 224, 3]);

      // Output buffer: shaped [1, numClasses] of doubles
      final numClasses = _interpreter!.getOutputTensor(0).shape[1];
      final outputBuffer = List.filled(1, List.filled(numClasses, 0.0));

      final start = DateTime.now();
      _interpreter!.run(input, outputBuffer);
      final time = DateTime.now().difference(start).inMilliseconds;

      AppLogger.info('Inference time: ${time}ms', 'DiseaseClassifier');

      // outputBuffer[0] is the flat scores list
      return List<double>.from(outputBuffer[0]);
    } catch (e, stack) {
      AppLogger.error('Inference failed', 'DiseaseClassifier', e);
      if (kDebugMode) print(stack);
      throw ModelException(
        ErrorCodes.errorMessages[ErrorCodes.inferenceFailed]!,
        ErrorCodes.inferenceFailed,
      );
    }
  }


  ClassificationResult getTopPrediction(List<double> scores) {
    double maxConfidence = 0.0;
    int maxIndex = 0;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxConfidence) {
        maxConfidence = scores[i];
        maxIndex = i;
      }
    }

    String className =
    maxIndex < classNames.length ? classNames[maxIndex] : 'Unknown';

    if (maxConfidence < confidenceThreshold) {
      className = 'Unknown';
      AppLogger.warning(
        'Low confidence: ${(maxConfidence * 100).toStringAsFixed(1)}%',
        'DiseaseClassifier',
      );
    }

    final result = ClassificationResult(
      className: className,
      classIndex: maxIndex,
      confidence: maxConfidence,
    );

    AppLogger.info('Prediction → $result', 'DiseaseClassifier');
    return result;
  }


  void close() {
    _interpreter?.close();
    _interpreter = null;
    AppLogger.info('Interpreter closed', 'DiseaseClassifier');
  }
}