import 'dart:io';
import '../constants/app_constants.dart';
import '../constants/error_codes.dart';


class Validators {

  static ValidationResult validateImageFormat(File imageFile) {
    final extension = imageFile.path.split('.').last.toLowerCase();

    if (!AppConstants.supportedImageFormats.contains(extension)) {
      return ValidationResult(
        isValid: false,
        errorCode: ErrorCodes.imgInvalidFormat,
        errorMessage: ErrorCodes.errorMessages[ErrorCodes.imgInvalidFormat]!,
      );
    }

    return ValidationResult(isValid: true);
  }


  static ValidationResult validateImageSize(File imageFile) {
    final fileSize = imageFile.lengthSync();

    if (fileSize > AppConstants.maxImageSizeBytes) {
      return ValidationResult(
        isValid: false,
        errorCode: ErrorCodes.imgFileTooLarge,
        errorMessage: ErrorCodes.errorMessages[ErrorCodes.imgFileTooLarge]!,
      );
    }

    return ValidationResult(isValid: true);
  }

  static ValidationResult validateImage(File imageFile) {
    final formatResult = validateImageFormat(imageFile);
    if (!formatResult.isValid) return formatResult;

    // Check size
    final sizeResult = validateImageSize(imageFile);
    if (!sizeResult.isValid) return sizeResult;

    return ValidationResult(isValid: true);
  }


  static bool validateConfidence(double confidence) {
    return confidence >= 0.0 && confidence <= 1.0;
  }


  static bool validateDiseaseName(String name) {
    if (name.isEmpty || name.length > 100) return false;
    final regex = RegExp(r'^[a-zA-Z0-9\s\-_]+$');
    return regex.hasMatch(name);
  }


  static bool validateUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }


  static bool validateTimestamp(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return timestamp <= now && timestamp > 0;
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorCode;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorCode,
    this.errorMessage,
  });
}