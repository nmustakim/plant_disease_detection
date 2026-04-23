
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/error_codes.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';

/// Classification Result

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

/// Disease Classifier (INT8 SAFE)

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

  /// Load TFLite Model

  Future<void> loadModel() async {
    try {
      AppLogger.info('Loading model: $modelPath', 'DiseaseClassifier');

      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false;

      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );

      final input = _interpreter!.getInputTensor(0);
      final output = _interpreter!.getOutputTensor(0);

      AppLogger.info('Model loaded successfully', 'DiseaseClassifier');
      AppLogger.info('Input  → ${input.shape} ${input.type}', 'DiseaseClassifier');
      AppLogger.info('Output → ${output.shape} ${output.type}', 'DiseaseClassifier');
    } catch (e, stack) {
      AppLogger.error('Model load failed', 'DiseaseClassifier', e);
      if (kDebugMode) {
        print(stack);
      }
      throw ModelException(
        ErrorCodes.errorMessages[ErrorCodes.modelLoadFailed]!,
        ErrorCodes.modelLoadFailed,
      );
    }
  }

  bool isModelLoaded() => _interpreter != null;


  /// Image Preprocessing (UINT8)

  Uint8List preprocessImage(img.Image image) {
    final resized = img.copyResize(image, width: 224, height: 224);

    final buffer = Uint8List(224 * 224 * 3);
    int index = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[index++] = pixel.r.toInt();
        buffer[index++] = pixel.g.toInt();
        buffer[index++] = pixel.b.toInt();
      }
    }
    return buffer;
  }


  /// Run Inference (INT8)

  Future<List<double>> runInference(Uint8List inputBuffer) async {
    if (!isModelLoaded()) {
      throw ModelException('Model not loaded', ErrorCodes.modelNotFound);
    }

    try {
      final input = inputBuffer.reshape([1, 224, 224, 3]);

      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputBuffer = Uint8List(outputTensor.shape[1]);

      final start = DateTime.now();
      _interpreter!.run(input, outputBuffer);
      final time = DateTime.now().difference(start).inMilliseconds;

      AppLogger.info('Inference time: ${time}ms', 'DiseaseClassifier');

      /// Convert UINT8 → confidence (0–1)
      return List<double>.generate(
        outputBuffer.length,
            (i) => outputBuffer[i] / 255.0,
      );
    } catch (e, stack) {
      AppLogger.error('Inference failed', 'DiseaseClassifier', e);
      if (kDebugMode) {
        print(stack);
      }
      throw ModelException(
        ErrorCodes.errorMessages[ErrorCodes.inferenceFailed]!,
        ErrorCodes.inferenceFailed,
      );
    }
  }


  /// Get Top Prediction

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


  /// Cleanup

  void close() {
    _interpreter?.close();
    _interpreter = null;
    AppLogger.info('Interpreter closed', 'DiseaseClassifier');
  }
}
