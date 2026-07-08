import 'package:flutter/foundation.dart';

/// Application environment configuration.
///
/// All values are read from compile-time environment variables (e.g.
/// `--dart-define=HOST=api.quraa.dev`) so that secrets and environment-specific
/// configuration are never bundled inside the app assets.
///
/// For local development, create a `.env` file in the project root and pass its
/// values via `--dart-define` flags. Do NOT add `.env` to `pubspec.yaml` assets
/// and do NOT commit it to version control.
abstract class Env {
  static const String appName = 'Quraaa';

  static const String _environmentKey = 'APP_ENV';
  static const String _hostKey = 'HOST';
  static const String _baseUrlKey = 'BASEURL';
  static const String _latestVersionKey = 'LATEST_VERSION';

  static String get environment {
    const String value = String.fromEnvironment(_environmentKey);
    if (value.isNotEmpty) return value;
    return kReleaseMode ? 'production' : 'development';
  }

  static bool get isDev =>
      environment == 'dev' || environment == 'development';

  /// Backend host (with optional scheme and port).
  ///
  /// Example: `api.quraa.dev` or `https://api.quraa.dev`.
  static String get host {
    const String value = String.fromEnvironment(_hostKey);
    if (value.isNotEmpty) return value;

    if (kReleaseMode) {
      throw StateError(
        'HOST must be provided via --dart-define in release builds.',
      );
    }

    // Development-only fallback. Use https so the scheme is never cleartext.
    return 'localhost:8080';
  }

  /// API path segment appended after the host.
  static String get baseUrl {
    const String value = String.fromEnvironment(_baseUrlKey);
    if (value.isNotEmpty) return value;

    if (kReleaseMode) {
      throw StateError(
        'BASEURL must be provided via --dart-define in release builds.',
      );
    }

    return 'api';
  }

  /// Fully qualified API base URL.
  ///
  /// If [host] does not include a scheme, `https://` is used. The app never
  /// falls back to unencrypted `http://`.
  static String get apiBaseUrl {
    final String rawHost = host;
    final String normalizedHost =
        rawHost.startsWith('http://') || rawHost.startsWith('https://')
            ? rawHost
            : 'https://$rawHost';
    return '$normalizedHost/$baseUrl';
  }

  static String? get latestVersion {
    const String value = String.fromEnvironment(_latestVersionKey);
    return value.isNotEmpty ? value : null;
  }
}
