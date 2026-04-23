
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

class PermissionException extends AppException {
  PermissionException(super.message, [super.code]);
}

class ValidationException extends AppException {
  ValidationException(super.message, [super.code]);
}

class ModelException extends AppException {
  ModelException(super.message, [super.code]);
}

class DatabaseException extends AppException {
  DatabaseException(super.message, [super.code]);
}

class NetworkException extends AppException {
  NetworkException(super.message, [super.code]);
}