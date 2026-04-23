import '../../core/constants/error_codes.dart';


class ErrorLog {
  final int? errorId; // Auto-increment PK
  final String errorCode;
  final String errorMessage;
  final ErrorType errorType;
  final String? predictionId; // Optional FK to predictions
  final int timestamp;
  final String? userAction;
  final String? deviceInfo;
  final ErrorSeverity severity;
  final bool resolved;

  ErrorLog({
    this.errorId,
    required this.errorCode,
    required this.errorMessage,
    required this.errorType,
    this.predictionId,
    required this.timestamp,
    this.userAction,
    this.deviceInfo,
    required this.severity,
    this.resolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'error_id': errorId,
      'error_code': errorCode,
      'error_message': errorMessage,
      'error_type': errorType.name.substring(0, 1).toUpperCase() +
          errorType.name.substring(1),
      'prediction_id': predictionId,
      'timestamp': timestamp,
      'user_action': userAction,
      'device_info': deviceInfo,
      'severity': severity.name.toUpperCase(),
      'resolved': resolved ? 1 : 0,
    };
  }

  /// Create from database map
  factory ErrorLog.fromMap(Map<String, dynamic> map) {
    return ErrorLog(
      errorId: map['error_id'] as int?,
      errorCode: map['error_code'] as String,
      errorMessage: map['error_message'] as String,
      errorType: _parseErrorType(map['error_type'] as String),
      predictionId: map['prediction_id'] as String?,
      timestamp: map['timestamp'] as int,
      userAction: map['user_action'] as String?,
      deviceInfo: map['device_info'] as String?,
      severity: _parseSeverity(map['severity'] as String),
      resolved: (map['resolved'] as int) == 1,
    );
  }

  static ErrorType _parseErrorType(String value) {
    switch (value.toLowerCase()) {
      case 'permission':
        return ErrorType.permission;
      case 'validation':
        return ErrorType.validation;
      case 'model':
        return ErrorType.model;
      case 'database':
        return ErrorType.database;
      case 'network':
        return ErrorType.network;
      default:
        return ErrorType.unknown;
    }
  }

  static ErrorSeverity _parseSeverity(String value) {
    switch (value.toLowerCase()) {
      case 'info':
        return ErrorSeverity.info;
      case 'warning':
        return ErrorSeverity.warning;
      case 'error':
        return ErrorSeverity.error;
      case 'critical':
        return ErrorSeverity.critical;
      default:
        return ErrorSeverity.error;
    }
  }

  @override
  String toString() {
    return 'ErrorLog(code: $errorCode, severity: ${severity.name})';
  }
}