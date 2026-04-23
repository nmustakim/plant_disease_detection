

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message, String tag) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  static void warning(String message, String tag) {
    if (kDebugMode) debugPrint('[$tag] $message');
  }

  static void error(String message, String tag, [Object? error]) {
    if (kDebugMode) debugPrint('[$tag] $message${error != null ? ' | $error' : ''}');
  }
}
