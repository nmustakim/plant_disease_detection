import '../../data/database/daos/error_logs_dao.dart';
import '../constants/error_codes.dart';

import '../utils/logger.dart';
import '../../data/models/error_log.dart';


class ErrorHandler {
  final ErrorLogsDao _errorLogsDao;

  ErrorHandler(this._errorLogsDao);

  Future<ErrorMessage> handleError(
      String errorCode, {
        String? predictionId,
        String? userAction,
        String? deviceInfo,
        dynamic originalError,
        StackTrace? stackTrace,
      }) async {
    final errorType = ErrorCodes.getErrorType(errorCode);
    final message = ErrorCodes.errorMessages[errorCode] ?? 'Unknown error occurred';
    final recovery = ErrorCodes.recoveryActions[errorCode] ?? 'Please try again';

    ErrorSeverity severity = ErrorSeverity.error;
    if (errorCode == ErrorCodes.confidenceBelowThreshold) {
      severity = ErrorSeverity.warning;
    } else if (errorCode == ErrorCodes.modelLoadFailed ||
        errorCode == ErrorCodes.dbCorrupt) {
      severity = ErrorSeverity.critical;
    }

    AppLogger.error(
      message,
      errorType.toString(),
      originalError,
      stackTrace,
    );

    try {
      final errorLog = ErrorLog(
        errorId: null, // Auto-increment
        errorCode: errorCode,
        errorMessage: message,
        errorType: errorType,
        predictionId: predictionId,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userAction: userAction,
        deviceInfo: deviceInfo,
        severity: severity,
        resolved: false,
      );

      await _errorLogsDao.insert(errorLog);
    } catch (e) {
      AppLogger.error('Failed to log error to database', 'ErrorHandler', e);
    }

    return ErrorMessage(
      code: errorCode,
      message: message,
      recovery: recovery,
      severity: severity,
    );
  }

  String getUserFriendlyMessage(String errorCode) {
    return ErrorCodes.errorMessages[errorCode] ?? 'An unexpected error occurred';
  }

  String getRecoveryAction(String errorCode) {
    return ErrorCodes.recoveryActions[errorCode] ?? 'Please try again';
  }
}

class ErrorMessage {
  final String code;
  final String message;
  final String recovery;
  final ErrorSeverity severity;

  ErrorMessage({
    required this.code,
    required this.message,
    required this.recovery,
    required this.severity,
  });
}