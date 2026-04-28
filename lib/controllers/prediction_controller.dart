import 'dart:io';
import 'dart:typed_data';
import '../services/image/image_processor.dart';
import '../services/image/image_service.dart';
import '../ml/disease_classifier.dart';
import '../data/database/database_manager.dart';
import '../data/models/prediction.dart';
import '../data/models/disease_info.dart';
import '../core/errors/error_handler.dart';
import '../core/errors/app_exceptions.dart';
import '../core/constants/error_codes.dart';
import '../core/utils/logger.dart';
import '../core/constants/app_constants.dart';

class PredictionResult {
  final Prediction prediction;
  final DiseaseInfo? diseaseInfo;
  final bool success;
  final String? errorMessage;

  PredictionResult({
    required this.prediction,
    this.diseaseInfo,
    this.success = true,
    this.errorMessage,
  });
}

class PredictionController {
  final ImageService imageService;
  final ImagePreprocessor preprocessor;
  final DiseaseClassifier mlModel;
  final DatabaseManager database;
  final ErrorHandler errorHandler;

  PredictionController({
    required this.imageService,
    required this.preprocessor,
    required this.mlModel,
    required this.database,
    required this.errorHandler,
  });

  Future<PredictionResult> captureAndClassify() async {
    try {
      AppLogger.info('Starting capture and classify workflow', 'PredictionController');
      final imageFile = await imageService.captureImage();
      return await classifyImage(imageFile);
    } catch (e, stackTrace) {
      AppLogger.error('Capture and classify failed', 'PredictionController', e, stackTrace);
      return _errorResult(e.toString());
    }
  }

  Future<PredictionResult> uploadAndClassify() async {
    try {
      AppLogger.info('Starting upload and classify workflow', 'PredictionController');
      final imageFile = await imageService.selectImage();
      return await classifyImage(imageFile);
    } catch (e, stackTrace) {
      AppLogger.error('Upload and classify failed', 'PredictionController', e, stackTrace);
      return _errorResult(e.toString());
    }
  }

  Future<PredictionResult> classifyImage(File imageFile) async {
    try {
      // 1. Preprocess → Float32List [224*224*3], normalised [0.0, 1.0]
      final Float32List tensor = await preprocessor.preprocessImage(imageFile);

      // 2. Ensure model is ready — loadModel() is void and throws on failure
      if (!mlModel.isModelLoaded()) {
        await mlModel.loadModel();
      }

      // 3. Run inference → List<double> confidence scores
      final List<double> scores = await mlModel.runInference(tensor);

      // 4. Pick top prediction
      final ClassificationResult classResult = mlModel.getTopPrediction(scores);

      AppLogger.info(
        'Classification result: ${classResult.className} '
            '(${(classResult.confidence * 100).toStringAsFixed(1)}%)',
        'PredictionController',
      );

      // 5. Resolve disease metadata
      DiseaseInfo? diseaseInfo;
      String diseaseId;
      String diseaseName;

      if (classResult.className != 'Unknown' &&
          classResult.confidence >= AppConstants.confidenceThreshold) {
        diseaseInfo = await database.getDiseaseInfo(classResult.className);

        if (diseaseInfo != null) {
          diseaseId   = diseaseInfo.diseaseId;
          diseaseName = diseaseInfo.diseaseName;
          AppLogger.info('Disease found in DB: $diseaseName', 'PredictionController');
        } else {
          // Fallback: derive readable name from class label
          diseaseId = classResult.className
              .toLowerCase()
              .replaceAll('___', '_')
              .replaceAll(' ', '_');
          diseaseName = classResult.className
              .replaceAll('___', ' - ')
              .replaceAll('_', ' ');
          AppLogger.info(
            'Disease not in DB, using formatted name: $diseaseName',
            'PredictionController',
          );
        }
      } else {
        diseaseId   = 'unknown_001';
        diseaseName = 'Unknown Disease';
        AppLogger.info(
          'Unknown / low-confidence result '
              '(${(classResult.confidence * 100).toStringAsFixed(1)}%)',
          'PredictionController',
        );
      }

      // 6. Persist prediction
      final prediction = Prediction(
        diseaseId:    diseaseId,
        diseaseName:  diseaseName,
        confidence:   classResult.confidence,
        imagePath:    imageFile.path,
        modelVersion: AppConstants.appVersion,
      );

      final savedPath       = await imageService.saveImage(imageFile, prediction.id);
      final savedPrediction = prediction.copyWith(imagePath: savedPath);
      await database.savePrediction(savedPrediction);

      AppLogger.info(
        'Prediction saved: ${savedPrediction.id} — $diseaseName',
        'PredictionController',
      );

      return PredictionResult(
        prediction:  savedPrediction,
        diseaseInfo: diseaseInfo,
        success:     true,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Classification failed', 'PredictionController', e, stackTrace);
      return _errorResult(e.toString());
    }
  }

  PredictionResult _errorResult(String message) => PredictionResult(
    prediction:   _createErrorPrediction(),
    success:      false,
    errorMessage: message,
  );

  Prediction _createErrorPrediction() => Prediction(
    diseaseId:    'error_001',
    diseaseName:  'Error',
    confidence:   0.0,
    imagePath:    '',
    modelVersion: AppConstants.appVersion,
  );
}