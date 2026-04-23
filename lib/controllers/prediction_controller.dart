
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../services/image/image_service.dart';
import '../services/image/image_preprocessor.dart';
import '../services/file/file_manager.dart';
import '../ml/disease_classifier.dart';
import '../data/database/database_manager.dart';
import '../data/database/daos/predictions_dao.dart';
import '../data/database/daos/disease_info_dao.dart';
import '../data/models/prediction.dart';
import '../data/models/disease_info.dart';
import '../core/errors/error_handler.dart';
import '../core/errors/app_error.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';

class PredictionController {
  final ImageService      imageService;
  final ImagePreprocessor preprocessor;
  final DiseaseClassifier mlModel;
  final DatabaseManager   database;
  final ErrorHandler      errorHandler;

  final FileManager _fileManager = FileManager();
  final _uuid = const Uuid();

  late final PredictionsDao _pDao = PredictionsDao(database);
  late final DiseaseInfoDao  _dDao = DiseaseInfoDao(database);

  PredictionController({
    required this.imageService,
    required this.preprocessor,
    required this.mlModel,
    required this.database,
    required this.errorHandler,
  });


  Future<File> startCapture()       async => imageService.captureImage();
  Future<File> startGalleryUpload() async => imageService.selectImage();

  Future<bool> validateImage(File imageFile) =>
      _fileManager.validateImage(imageFile).then((_) => true);


  Future<PredictionResult> runInference(File imageFile) async {
    try {
      final tensor = preprocessor.preprocessImage(imageFile);

      final result = await Future.any([
        Future(() => mlModel.classify(tensor)),
        Future.delayed(
          const Duration(milliseconds: AppConstants.inferenceTimeoutMs),
          () => throw AppError(
            code: AppErrorCode.inferenceTimeout,
            message: 'Inference took >2 seconds.',
          ),
        ),
      ]);

      DiseaseInfo? diseaseInfo;
      if (!result.isUnknown) {
        diseaseInfo = await _dDao.getByName(result.diseaseName);
      }

      final predictionId = _uuid.v4();
      final savedPath    = await _fileManager.saveImage(imageFile, predictionId);

      final prediction = Prediction(
        id:           predictionId,
        diseaseId:    diseaseInfo?.diseaseId ?? 'unknown',
        diseaseName:  result.diseaseName,
        confidence:   result.confidence,
        timestamp:    DateTime.now(),
        imagePath:    savedPath,
        modelVersion: AppConstants.modelVersion,
      );
      await _pDao.insert(prediction);

      AppLogger.info(
        'Inference complete: ${result.diseaseName} '
        '(${result.confidence.toStringAsFixed(2)})',
        'PredictionController',
      );

      return PredictionResult(prediction: prediction, diseaseInfo: diseaseInfo);
    } on AppError catch (e) {
      await errorHandler.handleError(e, userAction: 'runInference');
      rethrow;
    } catch (e) {
      final err = AppError(
        code: AppErrorCode.inferenceFailed,
        message: 'Unexpected error during inference.',
        originalError: e,
      );
      await errorHandler.handleError(err);
      throw err;
    }
  }
}

class PredictionResult {
  final Prediction   prediction;
  final DiseaseInfo? diseaseInfo;
  const PredictionResult({required this.prediction, this.diseaseInfo});
}
