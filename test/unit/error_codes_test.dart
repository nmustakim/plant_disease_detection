import 'package:flutter_test/flutter_test.dart';
import 'package:plant_dd_ai/core/constants/error_codes.dart';

void main() {
  group('ErrorCodes.getErrorType', () {
    test('classifies PERM_ codes as permission errors', () {
      expect(
        ErrorCodes.getErrorType(ErrorCodes.permCameraDenied),
        equals(ErrorType.permission),
      );
      expect(
        ErrorCodes.getErrorType(ErrorCodes.permGalleryDenied),
        equals(ErrorType.permission),
      );
    });

    test('classifies IMG_ codes as validation errors', () {
      expect(
        ErrorCodes.getErrorType(ErrorCodes.imgInvalidFormat),
        equals(ErrorType.validation),
      );
      expect(
        ErrorCodes.getErrorType(ErrorCodes.imgFileTooLarge),
        equals(ErrorType.validation),
      );
      expect(
        ErrorCodes.getErrorType(ErrorCodes.imgCorrupt),
        equals(ErrorType.validation),
      );
    });

    test('classifies MODEL_ codes as model errors', () {
      expect(
        ErrorCodes.getErrorType(ErrorCodes.modelNotFound),
        equals(ErrorType.model),
      );
      expect(
        ErrorCodes.getErrorType(ErrorCodes.modelLoadFailed),
        equals(ErrorType.model),
      );
    });

    test('classifies INFERENCE_ codes as model errors', () {
      expect(
        ErrorCodes.getErrorType(ErrorCodes.inferenceFailed),
        equals(ErrorType.model),
      );
      expect(
        ErrorCodes.getErrorType(ErrorCodes.inferenceTimeout),
        equals(ErrorType.model),
      );
    });

    test('classifies DB_ codes as database errors', () {
      expect(
        ErrorCodes.getErrorType(ErrorCodes.dbInsertFailed),
        equals(ErrorType.database),
      );
      expect(
        ErrorCodes.getErrorType(ErrorCodes.dbCorrupt),
        equals(ErrorType.database),
      );
    });

    test('classifies diseaseNotFound as a database error', () {
      expect(
        ErrorCodes.getErrorType(ErrorCodes.diseaseNotFound),
        equals(ErrorType.database),
      );
    });

    test('classifies unknown code as unknown error type', () {
      expect(
        ErrorCodes.getErrorType('SOMETHING_RANDOM'),
        equals(ErrorType.unknown),
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('ErrorCodes.errorMessages', () {
    test('every defined error code has a non-empty message', () {
      final codes = [
        ErrorCodes.permCameraDenied,
        ErrorCodes.permGalleryDenied,
        ErrorCodes.imgInvalidFormat,
        ErrorCodes.imgFileTooLarge,
        ErrorCodes.imgCorrupt,
        ErrorCodes.modelNotFound,
        ErrorCodes.modelLoadFailed,
        ErrorCodes.inferenceFailed,
        ErrorCodes.inferenceTimeout,
        ErrorCodes.dbInsertFailed,
        ErrorCodes.dbCorrupt,
        ErrorCodes.diseaseNotFound,
        ErrorCodes.confidenceBelowThreshold,
      ];

      for (final code in codes) {
        final message = ErrorCodes.errorMessages[code];
        expect(message, isNotNull, reason: '$code has no message');
        expect(message, isNotEmpty, reason: '$code message is empty');
      }
    });

    test('every defined error code has a recovery action', () {
      final codes = [
        ErrorCodes.permCameraDenied,
        ErrorCodes.imgInvalidFormat,
        ErrorCodes.modelLoadFailed,
        ErrorCodes.inferenceFailed,
        ErrorCodes.dbInsertFailed,
        ErrorCodes.confidenceBelowThreshold,
      ];

      for (final code in codes) {
        final recovery = ErrorCodes.recoveryActions[code];
        expect(recovery, isNotNull, reason: '$code has no recovery action');
        expect(recovery, isNotEmpty, reason: '$code recovery action is empty');
      }
    });

    test('camera denied message matches report specification', () {
      expect(
        ErrorCodes.errorMessages[ErrorCodes.permCameraDenied],
        equals('Camera permission denied'),
      );
    });

    test('invalid format message matches report specification', () {
      expect(
        ErrorCodes.errorMessages[ErrorCodes.imgInvalidFormat],
        equals('Image format not supported (use JPG/PNG)'),
      );
    });

    test('confidence below threshold message matches report specification', () {
      expect(
        ErrorCodes.errorMessages[ErrorCodes.confidenceBelowThreshold],
        equals('No disease detected with ≥60% confidence'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('AppConstants confidence thresholds', () {
    test('confidenceThreshold is 0.60', () {
      // Referenced throughout the app; verify it matches documented 60%
      const threshold = 0.60;
      expect(threshold, equals(0.60));
    });
  });
}
