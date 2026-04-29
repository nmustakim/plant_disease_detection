import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plant_dd_ai/controllers/prediction_controller.dart';
import 'package:plant_dd_ai/data/models/prediction.dart';
import 'package:plant_dd_ai/ml/disease_classifier.dart';
import 'package:plant_dd_ai/core/errors/app_exceptions.dart';
import 'package:plant_dd_ai/core/constants/error_codes.dart';
import 'prediction_controller_test.mocks.dart';

void main() {
  late MockDatabaseManager mockDb;
  late MockDiseaseClassifier mockClassifier;
  late MockImagePreprocessor mockPreprocessor;
  late MockImageService mockImageService;
  late MockErrorHandler mockErrorHandler;
  late PredictionController controller;
  late File fakeFile;

  setUp(() {
    mockDb = MockDatabaseManager();
    mockClassifier = MockDiseaseClassifier();
    mockPreprocessor = MockImagePreprocessor();
    mockImageService = MockImageService();
    mockErrorHandler = MockErrorHandler();

    controller = PredictionController(
      imageService: mockImageService,
      preprocessor: mockPreprocessor,
      mlModel: mockClassifier,
      database: mockDb,
      errorHandler: mockErrorHandler,
    );

    // Use a temp file so File() doesn't throw
    fakeFile = File('/tmp/test_leaf.jpg');
  });

  // Shared stub helpers ---------------------------------------------------
  void stubHighConfidencePipeline() {
    when(mockImageService.captureImage()).thenAnswer((_) async => fakeFile);
    when(mockImageService.selectImage()).thenAnswer((_) async => fakeFile);
    when(mockImageService.saveImage(any, any))
        .thenAnswer((_) async => '/saved/leaf.jpg');

    final tensor = Float32List(224 * 224 * 3);
    when(mockPreprocessor.preprocessImage(any)).thenAnswer((_) async => tensor);

    when(mockClassifier.isModelLoaded()).thenReturn(true);

    // 38 scores; index 29 → Tomato___Early_blight, confidence 0.92
    final scores = List<double>.filled(38, 0.01);
    scores[29] = 0.92;
    when(mockClassifier.runInference(any)).thenAnswer((_) async => scores);

    when(mockClassifier.getTopPrediction(any)).thenReturn(
      ClassificationResult(
        className: 'Tomato___Early_blight',
        classIndex: 29,
        confidence: 0.92,
      ),
    );

    when(mockDb.getDiseaseInfo('Tomato___Early_blight'))
        .thenAnswer((_) async => null); // no DB record — fallback name used

    when(mockDb.savePrediction(any)).thenAnswer((_) async => 'saved-id');
  }

  // -----------------------------------------------------------------------
  group('PredictionController.captureAndClassify', () {
    test('returns successful PredictionResult on happy path', () async {
      stubHighConfidencePipeline();

      final result = await controller.captureAndClassify();

      expect(result.success, isTrue);
      expect(result.prediction.diseaseName, isNotEmpty);
      expect(result.prediction.confidence, closeTo(0.92, 0.001));
      verify(mockImageService.captureImage()).called(1);
      verify(mockPreprocessor.preprocessImage(any)).called(1);
      verify(mockClassifier.runInference(any)).called(1);
      verify(mockDb.savePrediction(any)).called(1);
    });

    test('returns error result when captureImage throws PermissionException',
            () async {
          when(mockImageService.captureImage()).thenThrow(
            PermissionException('Camera denied', ErrorCodes.permCameraDenied),
          );

          final result = await controller.captureAndClassify();

          expect(result.success, isFalse);
          expect(result.errorMessage, isNotNull);
          verifyNever(mockPreprocessor.preprocessImage(any));
          verifyNever(mockDb.savePrediction(any));
        });

    test('loads model when isModelLoaded() returns false', () async {
      stubHighConfidencePipeline();
      when(mockClassifier.isModelLoaded()).thenReturn(false);
      when(mockClassifier.loadModel()).thenAnswer((_) async {});

      final result = await controller.captureAndClassify();

      expect(result.success, isTrue);
      verify(mockClassifier.loadModel()).called(1);
    });

    test('returns error result when model throws ModelException', () async {
      when(mockImageService.captureImage()).thenAnswer((_) async => fakeFile);
      final tensor = Float32List(224 * 224 * 3);
      when(mockPreprocessor.preprocessImage(any)).thenAnswer((_) async => tensor);
      when(mockClassifier.isModelLoaded()).thenReturn(false);
      when(mockClassifier.loadModel())
          .thenThrow(ModelException('Load failed', ErrorCodes.modelLoadFailed));

      final result = await controller.captureAndClassify();

      expect(result.success, isFalse);
      verifyNever(mockDb.savePrediction(any));
    });
  });

  group('PredictionController.uploadAndClassify', () {
    test('returns successful result when selecting from gallery', () async {
      stubHighConfidencePipeline();

      final result = await controller.uploadAndClassify();

      expect(result.success, isTrue);
      verify(mockImageService.selectImage()).called(1);
    });

    test('returns error result when selectImage throws ValidationException',
            () async {
          when(mockImageService.selectImage()).thenThrow(
            ValidationException('Bad format', ErrorCodes.imgInvalidFormat),
          );

          final result = await controller.uploadAndClassify();

          expect(result.success, isFalse);
          verifyNever(mockPreprocessor.preprocessImage(any));
        });
  });

  group('PredictionController — low confidence path', () {
    test('saves prediction with "Unknown Disease" when confidence < threshold',
            () async {
          when(mockImageService.captureImage()).thenAnswer((_) async => fakeFile);
          when(mockImageService.saveImage(any, any))
              .thenAnswer((_) async => '/saved/leaf.jpg');
          final tensor = Float32List(224 * 224 * 3);
          when(mockPreprocessor.preprocessImage(any)).thenAnswer((_) async => tensor);
          when(mockClassifier.isModelLoaded()).thenReturn(true);

          final scores = List<double>.filled(38, 0.01);
          scores[0] = 0.42; // below 0.60
          when(mockClassifier.runInference(any)).thenAnswer((_) async => scores);

          when(mockClassifier.getTopPrediction(any)).thenReturn(
            ClassificationResult(
              className: 'Unknown',
              classIndex: 0,
              confidence: 0.42,
            ),
          );

          when(mockDb.savePrediction(any)).thenAnswer((_) async => 'saved-id');

          final result = await controller.captureAndClassify();

          expect(result.success, isTrue);
          expect(result.prediction.diseaseId, equals('unknown_001'));
          expect(result.prediction.diseaseName, equals('Unknown Disease'));
        });
  });
}