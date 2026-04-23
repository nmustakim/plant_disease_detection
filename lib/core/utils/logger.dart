import 'package:flutter/foundation.dart';


class AppLogger {
  static const String _tag = 'PlantDiseaseDetector';

  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      print('[$_tag][INFO][${tag ?? 'APP'}] $message');
    }
  }

  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      print('[$_tag][DEBUG][${tag ?? 'APP'}] $message');
    }
  }

  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      print('[$_tag][WARNING][${tag ?? 'APP'}] $message');
    }
  }

  static void error(String message, [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag][ERROR][${tag ?? 'APP'}] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  static void critical(String message, [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag][CRITICAL][${tag ?? 'APP'}] $message');
    }
    if (error != null)  {if (kDebugMode) {
      print('Error: $error');
    }}
    if (stackTrace != null) {if (kDebugMode) {
      print('StackTrace: $stackTrace');
    }}
  }

  static void performance(String operation, int durationMs) {
    if (kDebugMode) {
      print('[$_tag][PERFORMANCE] $operation completed in ${durationMs}ms');
    }
  }
}