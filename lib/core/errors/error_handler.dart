
import '../utils/logger.dart';
import 'app_error.dart';
import '../../data/database/daos/error_logs_dao.dart';

class ErrorHandler {
  final ErrorLogsDao _dao;
  ErrorHandler(this._dao);

  Future<void> handleError(AppError error, {String? userAction}) async {
    AppLogger.error(error.message, 'ErrorHandler', error.originalError);
    try {
      await _dao.insertErrorLog(
        errorCode:    error.code.name.toUpperCase(),
        errorMessage: error.message,
        errorType:    _typeForCode(error.code),
        severity:     _severityForCode(error.code),
        userAction:   userAction,
      );
    } catch (_) {
    }
  }

  String userFriendlyMessage(AppErrorCode code) {
    switch (code) {
      case AppErrorCode.permCameraDenied:
        return 'Camera permission denied. Please allow access in Settings.';
      case AppErrorCode.permGalleryDenied:
        return 'Gallery permission denied. Please allow access in Settings.';
      case AppErrorCode.imgInvalidFormat:
        return 'Image format not supported. Please use JPG or PNG.';
      case AppErrorCode.imgFileTooLarge:
        return 'Image exceeds 10 MB limit. Please compress and retry.';
      case AppErrorCode.imgCorrupt:
        return 'Image file is corrupted. Please try again.';
      case AppErrorCode.modelNotFound:
        return 'Model file missing. Please reinstall the app.';
      case AppErrorCode.modelLoadFailed:
        return 'Failed to load model. Clear cache and restart the app.';
      case AppErrorCode.inferenceFailed:
        return 'Classification failed. Please restart the app.';
      case AppErrorCode.inferenceTimeout:
        return 'Classification took too long. Please retry.';
      case AppErrorCode.dbInsertFailed:
        return 'Failed to save prediction. Please retry.';
      case AppErrorCode.confidenceBelowThreshold:
        return 'Could not identify disease. Try a clearer photo in better light.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  String _typeForCode(AppErrorCode code) {
    if (code.name.startsWith('perm'))       return 'Permission';
    if (code.name.startsWith('img'))        return 'Validation';
    if (code.name.startsWith('model') ||
        code.name.startsWith('inference'))  return 'Model';
    if (code.name.startsWith('db'))         return 'Database';
    if (code.name.startsWith('network'))    return 'Network';
    return 'Unknown';
  }

  String _severityForCode(AppErrorCode code) {
    switch (code) {
      case AppErrorCode.modelNotFound:
      case AppErrorCode.modelLoadFailed:
      case AppErrorCode.inferenceFailed:
        return 'ERROR';
      case AppErrorCode.inferenceTimeout:
      case AppErrorCode.dbInsertFailed:
        return 'WARNING';
      default:
        return 'INFO';
    }
  }
}
