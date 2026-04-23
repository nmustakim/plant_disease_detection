// lib/data/database/daos/error_logs_dao.dart
// IT402 §4.2.5 – error_logs table DAO

import '../database_manager.dart';

class ErrorLogsDao {
  final DatabaseManager _db;
  ErrorLogsDao(this._db);

  Future<void> insertErrorLog({
    required String errorCode,
    required String errorMessage,
    required String errorType,
    required String severity,
    String? predictionId,
    String? userAction,
    String? deviceInfo,
  }) async {
    await _db.insert('error_logs', {
      'error_code':    errorCode,
      'error_message': errorMessage,
      'error_type':    errorType,
      'prediction_id': predictionId,
      'timestamp':     DateTime.now().millisecondsSinceEpoch,
      'user_action':   userAction,
      'device_info':   deviceInfo,
      'severity':      severity,
      'resolved':      0,
    });
  }
}
