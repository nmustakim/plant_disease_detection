enum ErrorType {
  permission,
  validation,
  model,
  database,
  network,
  unknown,
}

enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

class ErrorCodes {
  static const String permCameraDenied = 'PERM_CAMERA_DENIED';
  static const String permGalleryDenied = 'PERM_GALLERY_DENIED';

  static const String imgInvalidFormat = 'IMG_INVALID_FORMAT';
  static const String imgFileTooLarge = 'IMG_FILE_TOO_LARGE';
  static const String imgCorrupt = 'IMG_CORRUPT';

  static const String modelNotFound = 'MODEL_NOT_FOUND';
  static const String modelLoadFailed = 'MODEL_LOAD_FAILED';
  static const String inferenceFailed = 'INFERENCE_FAILED';
  static const String inferenceTimeout = 'INFERENCE_TIMEOUT';

  static const String dbInsertFailed = 'DB_INSERT_FAILED';
  static const String dbCorrupt = 'DB_CORRUPT';
  static const String diseaseNotFound = 'DISEASE_NOT_FOUND';

  static const String confidenceBelowThreshold = 'CONFIDENCE_BELOW_THRESHOLD';

  static const Map<String, String> errorMessages = {
    permCameraDenied: 'Camera permission denied',
    permGalleryDenied: 'Gallery permission denied',
    imgInvalidFormat: 'Image format not supported (use JPG/PNG)',
    imgFileTooLarge: 'Image exceeds 10MB limit',
    imgCorrupt: 'Image file is corrupted',
    modelNotFound: 'TFLite model file missing',
    modelLoadFailed: 'Failed to load inference model',
    inferenceFailed: 'Model inference crashed',
    inferenceTimeout: 'Inference took >2 seconds',
    dbInsertFailed: 'Failed to save prediction to database',
    dbCorrupt: 'Database file is corrupted',
    diseaseNotFound: 'Disease information not found',
    confidenceBelowThreshold: 'No disease detected with ≥60% confidence',
  };

  static const Map<String, String> recoveryActions = {
    permCameraDenied: 'Show settings dialog',
    permGalleryDenied: 'Show settings dialog',
    imgInvalidFormat: 'Retry capture/upload',
    imgFileTooLarge: 'Compress and retry',
    imgCorrupt: 'Retry capture/upload',
    modelNotFound: 'Reinstall app',
    modelLoadFailed: 'Clear cache, restart app',
    inferenceFailed: 'Restart app',
    inferenceTimeout: 'Retry or restart app',
    dbInsertFailed: 'Retry operation',
    dbCorrupt: 'Reinstall app',
    diseaseNotFound: 'Update disease database',
    confidenceBelowThreshold: 'Result marked as "Unknown"',
  };

  static ErrorType getErrorType(String errorCode) {
    if (errorCode.startsWith('PERM_')) return ErrorType.permission;
    if (errorCode.startsWith('IMG_')) return ErrorType.validation;
    if (errorCode.startsWith('MODEL_') || errorCode.startsWith('INFERENCE_')) {
      return ErrorType.model;
    }
    if (errorCode.startsWith('DB_') || errorCode == diseaseNotFound) {
      return ErrorType.database;
    }
    return ErrorType.unknown;
  }
}