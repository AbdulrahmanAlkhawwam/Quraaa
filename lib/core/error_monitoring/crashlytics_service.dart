import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  CrashlyticsService();

  FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  Future<void> initialize({bool enableCollection = true}) async {
    if (kIsWeb) {
      return;
    }

    try {
      await _instance.setCrashlyticsCollectionEnabled(enableCollection);
    } catch (_) {
      // Crashlytics is optional during local setup; the app should stay healthy.
    }
  }

  Future<void> setUserIdentifier(String identifier) async {
    await _runSafely(() => _instance.setUserIdentifier(identifier));
  }

  Future<void> setCustomKey(String key, Object value) async {
    await _runSafely(() => _instance.setCustomKey(key, value));
  }

  Future<void> setCustomKeys(Map<String, Object> values) async {
    for (final MapEntry<String, Object> entry in values.entries) {
      await setCustomKey(entry.key, entry.value);
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
    Iterable<Object> information = const <Object>[],
  }) async {
    await _runSafely(
      () => _instance.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: reason,
        information: information,
      ),
    );
  }

  Future<void> recordFlutterFatalError(
    FlutterErrorDetails details,
  ) async {
    await _runSafely(() => _instance.recordFlutterFatalError(details));
  }

  Future<void> log(String message) async {
    await _runSafely(() => _instance.log(message));
  }

  Future<void> _runSafely(Future<void> Function() action) async {
    if (kIsWeb) {
      return;
    }

    try {
      await action();
    } catch (_) {
      // Never allow monitoring to crash the app.
    }
  }
}
