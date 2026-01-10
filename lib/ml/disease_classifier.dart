
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

      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false;

      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );

      // Get detailed model info
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      AppLogger.info('Model loaded successfully', 'DiseaseClassifier');
      AppLogger.info('═══════════════════════════════════', 'DiseaseClassifier');
      AppLogger.info('INPUT TENSOR INFO:', 'DiseaseClassifier');
      AppLogger.info('  Shape: ${inputTensor.shape}', 'DiseaseClassifier');
      AppLogger.info('  Type: ${inputTensor.type}', 'DiseaseClassifier');
      AppLogger.info('  Name: ${inputTensor.name}', 'DiseaseClassifier');
      AppLogger.info('OUTPUT TENSOR INFO:', 'DiseaseClassifier');
      AppLogger.info('  Shape: ${outputTensor.shape}', 'DiseaseClassifier');
      AppLogger.info('  Type: ${outputTensor.type}', 'DiseaseClassifier');
      AppLogger.info('  Name: ${outputTensor.name}', 'DiseaseClassifier');
      AppLogger.info('═══════════════════════════════════', 'DiseaseClassifier');

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load model', 'DiseaseClassifier', e);
      print('Stack trace: $stackTrace');
      throw ModelException(
        ErrorCodes.errorMessages[ErrorCodes.modelLoadFailed]!,
        ErrorCodes.modelLoadFailed,
      );
    }
  }
  // Rest of your code stays the same...
  Future<List<double>> runInference(List<List<List<double>>> inputTensor) async {
    if (!isModelLoaded()) {
      throw ModelException('Model not loaded', ErrorCodes.modelNotFound);
    }

    try {
      AppLogger.info('═══ INFERENCE DEBUG START ═══', 'DiseaseClassifier');

      // Get model expectations
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputType = _interpreter!.getInputTensor(0).type;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      AppLogger.info('Model expects: $inputShape ($inputType)', 'DiseaseClassifier');
      AppLogger.info('Model outputs: $outputShape', 'DiseaseClassifier');

      // Debug input tensor
      AppLogger.info('Input tensor: [${inputTensor.length}][${inputTensor[0].length}][${inputTensor[0][0].length}]', 'DiseaseClassifier');
      AppLogger.info('Sample pixels:', 'DiseaseClassifier');
      AppLogger.info('  [0][0] = ${inputTensor[0][0]}', 'DiseaseClassifier');
      AppLogger.info('  [112][112] = ${inputTensor[112][112]}', 'DiseaseClassifier');

      // ⚠️ CRITICAL: Wrap in batch dimension
      // TFLite expects [batch, height, width, channels]
      final input = [inputTensor];  // This creates [1, 224, 224, 3]

      AppLogger.info('Wrapped input shape: [1][${inputTensor.length}][${inputTensor[0].length}][${inputTensor[0][0].length}]', 'DiseaseClassifier');

      final numClasses = outputShape[1];
      final output = List.generate(1, (_) => List.filled(numClasses, 0.0));

      AppLogger.info('Running model.run()...', 'DiseaseClassifier');
      final inferenceStart = DateTime.now();

      _interpreter!.run(input, output);

      final inferenceTime = DateTime.now().difference(inferenceStart).inMilliseconds;
      AppLogger.info('Inference completed in ${inferenceTime}ms', 'DiseaseClassifier');

      // Debug output
      final scores = output[0];
      AppLogger.info('Raw scores (${scores.length} classes):', 'DiseaseClassifier');

      // Print all scores
      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > 0.01) {  // Only print significant scores
          AppLogger.info('  Class $i: ${(scores[i] * 100).toStringAsFixed(2)}%', 'DiseaseClassifier');
        }
      }

      final sum = scores.reduce((a, b) => a + b);
      final max = scores.reduce((a, b) => a > b ? a : b);
      AppLogger.info('Sum: ${sum.toStringAsFixed(4)}, Max: ${(max * 100).toStringAsFixed(2)}%', 'DiseaseClassifier');
      AppLogger.info('═══ INFERENCE DEBUG END ═══', 'DiseaseClassifier');

      return scores;
    } catch (e, stack) {
      AppLogger.error('Inference failed', 'DiseaseClassifier', e);
      print('ERROR: $e');
      print('STACK: $stack');
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