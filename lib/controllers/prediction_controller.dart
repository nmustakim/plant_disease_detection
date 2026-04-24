import 'dart:io';
import '../services/image/image_processor.dart';
import '../services/image/image_service.dart';
import '../ml/disease_classifier.dart';
import '../data/database/database_manager.dart';
import '../data/models/prediction.dart';
import '../data/models/disease_info.dart';
import '../core/errors/error_handler.dart';
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

      // Step 1-4: Capture image
      final imageFile = await imageService.captureImage();

      // Continue with classification
      return await classifyImage(imageFile);
    } catch (e, stackTrace) {
      AppLogger.error('Capture and classify failed', 'PredictionController', e, stackTrace);
      return PredictionResult(
        prediction: _createErrorPrediction(),
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<PredictionResult> uploadAndClassify() async {
    try {
      AppLogger.info('Starting upload and classify workflow', 'PredictionController');

      // Select image from gallery
      final imageFile = await imageService.selectImage();

      // Continue with classification
      return await classifyImage(imageFile);
    } catch (e, stackTrace) {
      AppLogger.error('Upload and classify failed', 'PredictionController', e, stackTrace);
      return PredictionResult(
        prediction: _createErrorPrediction(),
        success: false,
        errorMessage: e.toString(),
      );
    }
  }


  Future<PredictionResult> classifyImage(File imageFile) async {
    try {
      final tensor = await preprocessor.preprocessImage(imageFile);

      if (!mlModel.isModelLoaded()) {
        await mlModel.loadModel();
      }

      final scores = await mlModel.runInference(tensor);

      final classResult = mlModel.getTopPrediction(scores);

      DiseaseInfo? diseaseInfo;
      String diseaseId = 'unknown_001';

      if (classResult.className != 'Unknown') {
        diseaseInfo = await database.getDiseaseInfo(classResult.className);
        if (diseaseInfo != null) {
          diseaseId = diseaseInfo.diseaseId;
        }
      }

      // Create prediction record
      final prediction = Prediction(
        diseaseId: diseaseId,
        diseaseName: classResult.className,
        confidence: classResult.confidence,
        imagePath: imageFile.path,
        modelVersion: AppConstants.appVersion,
      );

      // Step 9: Save to database
      final savedPath = await imageService.saveImage(imageFile, prediction.id);
      final updatedPrediction = prediction.copyWith(imagePath: savedPath);
      await database.savePrediction(updatedPrediction);

      AppLogger.info('Prediction saved: ${prediction.id}', 'PredictionController');

      return PredictionResult(
        prediction: updatedPrediction,
        diseaseInfo: diseaseInfo,
        success: true,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Classification failed', 'PredictionController', e, stackTrace);
      return PredictionResult(
        prediction: _createErrorPrediction(),
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Prediction _createErrorPrediction() {
    return Prediction(
      diseaseId: 'error_001',
      diseaseName: 'Error',
      confidence: 0.0,
      imagePath: '',
      modelVersion: AppConstants.appVersion,
    );
  }
}