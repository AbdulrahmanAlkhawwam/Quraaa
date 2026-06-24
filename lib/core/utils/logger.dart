import 'package:flutter/foundation.dart';

/// Lightweight structured logger for debug builds.
///
/// Migrated from quraa_otp. Only emits output in debug mode to avoid leaking
/// sensitive information in release builds.
abstract final class AppLogger {
  /// Logs an informational message.
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] ${DateTime.now().toIso8601String()} - $message');
    }
  }

  /// Logs an error with optional details.
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('[ERROR] ${DateTime.now().toIso8601String()} - $message');
      if (error != null) {
        debugPrint('  Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('  StackTrace: $stackTrace');
      }
    }
  }
}
