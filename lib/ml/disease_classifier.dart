
import 'package:tflite_flutter/tflite_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/error_codes.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';

class ClassificationResult {
  final String className;
  final int classIndex;
  final double confidence;

  ClassificationResult({
    required this.className,
    required this.classIndex,
    required this.confidence,
  });

  bool get isHighConfidence => confidence >= AppConstants.highConfidenceThreshold;
  bool get isMediumConfidence =>
      confidence >= AppConstants.mediumConfidenceThreshold &&
          confidence < AppConstants.highConfidenceThreshold;
  bool get isLowConfidence => confidence < AppConstants.mediumConfidenceThreshold;

  @override
  String toString() => 'ClassificationResult(class: $className, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}




class DiseaseClassifier {
  Interpreter? _interpreter;
  final String modelPath;
  final String modelVersion;
  final List<String> classNames;
  final double confidenceThreshold;

  DiseaseClassifier({
    this.modelPath = AppConstants.modelAssetPath,
    this.modelVersion = AppConstants.appVersion,
    this.classNames = AppConstants.diseaseClasses,
    this.confidenceThreshold = AppConstants.confidenceThreshold,
  });

  Future<bool> loadModel() async {
    try {
      AppLogger.info('Loading TFLite model from $modelPath...', 'DiseaseClassifier');

      // Create interpreter with options for better compatibility
      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false;  // Disable NNAPI to avoid compatibility issues

      // Load model from assets
      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );

      // Get model input/output info
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final inputType = _interpreter!.getInputTensor(0).type;
      final outputType = _interpreter!.getOutputTensor(0).type;

      AppLogger.info('Model loaded successfully', 'DiseaseClassifier');
      AppLogger.info('Input shape: $inputShape, type: $inputType', 'DiseaseClassifier');
      AppLogger.info('Output shape: $outputShape, type: $outputType', 'DiseaseClassifier');

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load model', 'DiseaseClassifier', e);
      print('Stack trace: $stackTrace'); // Debug info
      throw ModelException(
        ErrorCodes.errorMessages[ErrorCodes.modelLoadFailed]!,
        ErrorCodes.modelLoadFailed,
      );
    }
  }

  // Rest of your code stays the same...
  Future<List<double>> runInference(List<List<List<double>>> inputTensor) async {
    if (!isModelLoaded()) {
      throw ModelException(
        'Model not loaded',
        ErrorCodes.modelNotFound,
      );
    }

    try {
      AppLogger.info('Running inference...', 'DiseaseClassifier');
      final startTime = DateTime.now();

      // Prepare input: [1, height, width, channels]
      final input = [inputTensor];

      // Prepare output buffer: [1, numClasses]
      final output = List.filled(1, List.filled(classNames.length, 0.0))
          .map((e) => List<double>.from(e))
          .toList();

      // Run inference
      _interpreter!.run(input, output);

      // Extract probabilities from output
      final probabilities = output[0];

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.performance('Inference', duration);

      if (duration > AppConstants.maxInferenceTimeMillis) {
        AppLogger.warning(
          'Inference took ${duration}ms (exceeds ${AppConstants.maxInferenceTimeMillis}ms threshold)',
          'DiseaseClassifier',
        );
      }

      return probabilities;
    } catch (e) {
      AppLogger.error('Inference failed', 'DiseaseClassifier', e);
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

    String className = maxIndex < classNames.length
        ? classNames[maxIndex]
        : 'Unknown';

    if (maxConfidence < confidenceThreshold) {
      className = 'Unknown';
      AppLogger.warning(
        'Confidence ${(maxConfidence * 100).toStringAsFixed(1)}% below threshold ${(confidenceThreshold * 100).toStringAsFixed(1)}%',
        'DiseaseClassifier',
      );
    }

    final result = ClassificationResult(
      className: className,
      classIndex: maxIndex,
      confidence: maxConfidence,
    );

    AppLogger.info('Top prediction: $result', 'DiseaseClassifier');
    return result;
  }

  bool isModelLoaded() => _interpreter != null;

  void close() {
    _interpreter?.close();
    _interpreter = null;
    AppLogger.info('Model interpreter closed', 'DiseaseClassifier');
  }
}