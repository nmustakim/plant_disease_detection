// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

import 'dart:io';
import 'dart:typed_data';
import 'package:mockito/mockito.dart';
import 'package:plant_dd_ai/core/constants/error_codes.dart';
import 'package:plant_dd_ai/data/database/database_manager.dart';
import 'package:plant_dd_ai/data/models/prediction.dart';
import 'package:plant_dd_ai/data/models/disease_info.dart';
import 'package:plant_dd_ai/data/models/error_log.dart';
import 'package:plant_dd_ai/ml/disease_classifier.dart';
import 'package:plant_dd_ai/services/image/image_processor.dart';
import 'package:plant_dd_ai/services/image/image_service.dart';
import 'package:plant_dd_ai/core/errors/error_handler.dart';

// ─── MockDatabaseManager ────────────────────────────────────────────────────

class MockDatabaseManager extends Mock implements DatabaseManager {
  @override
  Future<String> savePrediction(Prediction? prediction) =>
      (super.noSuchMethod(
        Invocation.method(#savePrediction, [prediction]),
        returnValue: Future.value(''),
        returnValueForMissingStub: Future.value(''),
      ) as Future<String>);

  @override
  Future<List<Prediction>> getAllPredictions() =>
      (super.noSuchMethod(
        Invocation.method(#getAllPredictions, []),
        returnValue: Future.value(<Prediction>[]),
        returnValueForMissingStub: Future.value(<Prediction>[]),
      ) as Future<List<Prediction>>);

  @override
  Future<Prediction?> getPredictionById(String? id) =>
      (super.noSuchMethod(
        Invocation.method(#getPredictionById, [id]),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      ) as Future<Prediction?>);

  @override
  Future<bool> deletePrediction(String? id) =>
      (super.noSuchMethod(
        Invocation.method(#deletePrediction, [id]),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      ) as Future<bool>);

  @override
  Future<bool> deleteAllPredictions() =>
      (super.noSuchMethod(
        Invocation.method(#deleteAllPredictions, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      ) as Future<bool>);

  @override
  Future<DiseaseInfo?> getDiseaseInfo(String? diseaseName) =>
      (super.noSuchMethod(
        Invocation.method(#getDiseaseInfo, [diseaseName]),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      ) as Future<DiseaseInfo?>);

  @override
  Future<DiseaseInfo?> getDiseaseInfoById(String? diseaseId) =>
      (super.noSuchMethod(
        Invocation.method(#getDiseaseInfoById, [diseaseId]),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      ) as Future<DiseaseInfo?>);
}

// ─── MockDiseaseClassifier ───────────────────────────────────────────────────

class MockDiseaseClassifier extends Mock implements DiseaseClassifier {
  @override
  Future<void> loadModel() =>
      (super.noSuchMethod(
        Invocation.method(#loadModel, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      ) as Future<void>);

  @override
  Future<void> loadModelFromFile(String? filePath) =>
      (super.noSuchMethod(
        Invocation.method(#loadModelFromFile, [filePath]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      ) as Future<void>);

  @override
  bool isModelLoaded() =>
      (super.noSuchMethod(
        Invocation.method(#isModelLoaded, []),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  Future<List<double>> runInference(Float32List? inputBuffer) =>
      (super.noSuchMethod(
        Invocation.method(#runInference, [inputBuffer]),
        returnValue: Future.value(<double>[]),
        returnValueForMissingStub: Future.value(<double>[]),
      ) as Future<List<double>>);

  @override
  ClassificationResult getTopPrediction(List<double>? scores) =>
      (super.noSuchMethod(
        Invocation.method(#getTopPrediction, [scores]),
        returnValue: ClassificationResult(
          className: 'Unknown',
          classIndex: 0,
          confidence: 0.0,
        ),
        returnValueForMissingStub: ClassificationResult(
          className: 'Unknown',
          classIndex: 0,
          confidence: 0.0,
        ),
      ) as ClassificationResult);

  @override
  void close() => super.noSuchMethod(
    Invocation.method(#close, []),
    returnValueForMissingStub: null,
  );
}

// ─── MockImagePreprocessor ───────────────────────────────────────────────────

class MockImagePreprocessor extends Mock implements ImagePreprocessor {
  @override
  Future<Float32List> preprocessImage(File? imageFile) =>
      (super.noSuchMethod(
        Invocation.method(#preprocessImage, [imageFile]),
        returnValue: Future.value(Float32List(0)),
        returnValueForMissingStub: Future.value(Float32List(0)),
      ) as Future<Float32List>);
}

// ─── MockImageService ────────────────────────────────────────────────────────

class MockImageService extends Mock implements ImageService {
  @override
  Future<File> captureImage() =>
      (super.noSuchMethod(
        Invocation.method(#captureImage, []),
        returnValue: Future.value(File('')),
        returnValueForMissingStub: Future.value(File('')),
      ) as Future<File>);

  @override
  Future<File> selectImage() =>
      (super.noSuchMethod(
        Invocation.method(#selectImage, []),
        returnValue: Future.value(File('')),
        returnValueForMissingStub: Future.value(File('')),
      ) as Future<File>);

  @override
  Future<String> saveImage(File? imageFile, String? predictionId) =>
      (super.noSuchMethod(
        Invocation.method(#saveImage, [imageFile, predictionId]),
        returnValue: Future.value(''),
        returnValueForMissingStub: Future.value(''),
      ) as Future<String>);

  @override
  Future<bool> deleteImage(String? imagePath) =>
      (super.noSuchMethod(
        Invocation.method(#deleteImage, [imagePath]),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      ) as Future<bool>);

  @override
  bool validateImageFormat(File? file) =>
      (super.noSuchMethod(
        Invocation.method(#validateImageFormat, [file]),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  bool validateImageSize(File? file) =>
      (super.noSuchMethod(
        Invocation.method(#validateImageSize, [file]),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
}

// ─── MockErrorHandler ────────────────────────────────────────────────────────

class MockErrorHandler extends Mock implements ErrorHandler {
  @override
  Future<ErrorMessage> handleError(
      String? errorCode, {
        String? predictionId,
        String? userAction,
        String? deviceInfo,
        dynamic originalError,
        StackTrace? stackTrace,
      }) =>
      (super.noSuchMethod(
        Invocation.method(#handleError, [errorCode], {
          #predictionId: predictionId,
          #userAction: userAction,
          #deviceInfo: deviceInfo,
          #originalError: originalError,
          #stackTrace: stackTrace,
        }),
        returnValue: Future.value(ErrorMessage(
          code: errorCode ?? '',
          message: '',
          recovery: '',
          severity: ErrorSeverity.error,
        )),
        returnValueForMissingStub: Future.value(ErrorMessage(
          code: errorCode ?? '',
          message: '',
          recovery: '',
          severity: ErrorSeverity.error,
        )),
      ) as Future<ErrorMessage>);

  @override
  String getUserFriendlyMessage(String? errorCode) =>
      (super.noSuchMethod(
        Invocation.method(#getUserFriendlyMessage, [errorCode]),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);

  @override
  String getRecoveryAction(String? errorCode) =>
      (super.noSuchMethod(
        Invocation.method(#getRecoveryAction, [errorCode]),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
}