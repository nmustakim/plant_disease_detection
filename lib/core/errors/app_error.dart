



enum AppErrorCode {
  permCameraDenied,
  permGalleryDenied,

  imgInvalidFormat,
  imgFileTooLarge,
  imgCorrupt,

  modelNotFound,
  modelLoadFailed,
  inferenceFailed,
  inferenceTimeout,

  dbInsertFailed,
  dbQueryFailed,

  networkUnavailable,

  confidenceBelowThreshold,

  unknown,
}

class AppError implements Exception {
  final AppErrorCode code;
  final String message;
  final Object? originalError;

  const AppError({
    required this.code,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'AppError(${code.name}): $message';
}
