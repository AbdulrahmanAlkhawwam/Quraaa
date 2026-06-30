import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../config/env/env.dart';
import 'crashlytics_service.dart';
import 'device_info_provider.dart';
import 'error_report.dart';
import 'navigation_tracker.dart';
import 'telegram_notification_service.dart';
import 'user_context_provider.dart';

abstract class AppLogger {
  Future<void> initialize();

  void debug(String message, {String? source, Map<String, Object?>? data});
  void info(String message, {String? source, Map<String, Object?>? data});
  void warning(String message, {String? source, Map<String, Object?>? data});

  Future<void> recordUserAction(
    String action, {
    String? source,
  });

  Future<void> setUserContext({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? subscriptionStatus,
  });

  Future<void> setLanguage(String language);

  Future<void> setRouteContext({
    String? currentRoute,
    String? previousRoute,
    List<String>? navigationHistory,
  });

  Future<void> error(
    Object error, {
    StackTrace? stackTrace,
    String? message,
    String? source,
    bool fatal = false,
    String? apiMethod,
    String? apiUrl,
    int? apiStatusCode,
    Duration? apiDuration,
    String? apiRequestBody,
    String? apiResponseBody,
  });

  Future<void> fatal(
    Object error, {
    StackTrace? stackTrace,
    String? message,
    String? source,
    String? apiMethod,
    String? apiUrl,
    int? apiStatusCode,
    Duration? apiDuration,
    String? apiRequestBody,
    String? apiResponseBody,
  });

  Future<void> recordFlutterError(FlutterErrorDetails details);
  Future<void> recordPlatformDispatcherError(Object error, StackTrace stackTrace);
  Future<void> recordAsyncError(
    Object error,
    StackTrace stackTrace, {
    String? source,
    bool fatal = true,
  });
  Future<void> recordBlocError(
    Object error,
    StackTrace stackTrace, {
    String? bloc,
    String? event,
  });
}

typedef LoggerService = AppLogger;

class AppLoggerImpl implements AppLogger {
  AppLoggerImpl({
    required this._crashlyticsService,
    required this._telegramNotificationService,
    required this._navigationTracker,
    required this._userContextProvider,
    required this._deviceInfoProvider,
  });

  final CrashlyticsService _crashlyticsService;
  final TelegramNotificationService _telegramNotificationService;
  final NavigationTracker _navigationTracker;
  final UserContextProvider _userContextProvider;
  final DeviceInfoProvider _deviceInfoProvider;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await _deviceInfoProvider.initialize();
      await _userContextProvider.initialize();
      await _crashlyticsService.initialize(enableCollection: true);
      _navigationTracker.setOnChanged(() {
        unawaited(_syncCrashlyticsKeys());
      });
      _navigationTracker.setRouteContext(currentRoute: 'splash');
      await _syncCrashlyticsKeys();
    } catch (error, stackTrace) {
      _logLocal(
        'WARNING',
        'AppLogger initialization fallback: $error',
        source: 'AppLogger',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _initialized = true;
    }
  }

  @override
  void debug(String message, {String? source, Map<String, Object?>? data}) {
    _logLocal('DEBUG', message, source: source, data: data);
  }

  @override
  void info(String message, {String? source, Map<String, Object?>? data}) {
    _logLocal('INFO', message, source: source, data: data);
  }

  @override
  void warning(String message, {String? source, Map<String, Object?>? data}) {
    _logLocal('WARNING', message, source: source, data: data);
  }

  @override
  Future<void> recordUserAction(
    String action, {
    String? source,
  }) async {
    await _userContextProvider.recordAction(action);
    await _syncCrashlyticsKeys();
    _logLocal('ACTION', action, source: source);
  }

  @override
  Future<void> setUserContext({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? subscriptionStatus,
  }) async {
    await _userContextProvider.setUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      subscriptionStatus: subscriptionStatus,
    );
    await _syncCrashlyticsKeys();
  }

  @override
  Future<void> setLanguage(String language) async {
    await _userContextProvider.setLanguage(language);
    await _syncCrashlyticsKeys();
  }

  @override
  Future<void> setRouteContext({
    String? currentRoute,
    String? previousRoute,
    List<String>? navigationHistory,
  }) async {
    if (currentRoute != null ||
        previousRoute != null ||
        navigationHistory != null) {
      _navigationTracker.setRouteContext(
        currentRoute: currentRoute,
        previousRoute: previousRoute,
        navigationHistory: navigationHistory,
      );
    }
    await _syncCrashlyticsKeys();
  }

  @override
  Future<void> error(
    Object error, {
    StackTrace? stackTrace,
    String? message,
    String? source,
    bool fatal = false,
    String? apiMethod,
    String? apiUrl,
    int? apiStatusCode,
    Duration? apiDuration,
    String? apiRequestBody,
    String? apiResponseBody,
  }) async {
    await _record(
      error,
      stackTrace: stackTrace,
      message: message,
      source: source,
      fatal: fatal,
      apiMethod: apiMethod,
      apiUrl: apiUrl,
      apiStatusCode: apiStatusCode,
      apiDuration: apiDuration,
      apiRequestBody: apiRequestBody,
      apiResponseBody: apiResponseBody,
    );
  }

  @override
  Future<void> fatal(
    Object error, {
    StackTrace? stackTrace,
    String? message,
    String? source,
    String? apiMethod,
    String? apiUrl,
    int? apiStatusCode,
    Duration? apiDuration,
    String? apiRequestBody,
    String? apiResponseBody,
  }) async {
    await _record(
      error,
      stackTrace: stackTrace,
      message: message,
      source: source,
      fatal: true,
      apiMethod: apiMethod,
      apiUrl: apiUrl,
      apiStatusCode: apiStatusCode,
      apiDuration: apiDuration,
      apiRequestBody: apiRequestBody,
      apiResponseBody: apiResponseBody,
    );
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    await _record(
      details.exception,
      stackTrace: details.stack ?? StackTrace.current,
      message: details.exceptionAsString(),
      source: 'FlutterError',
      fatal: false,
    );
  }

  @override
  Future<void> recordPlatformDispatcherError(
    Object error,
    StackTrace stackTrace,
  ) async {
    await _record(
      error,
      stackTrace: stackTrace,
      message: error.toString(),
      source: 'PlatformDispatcher',
      fatal: true,
    );
  }

  @override
  Future<void> recordAsyncError(
    Object error,
    StackTrace stackTrace, {
    String? source,
    bool fatal = true,
  }) async {
    await _record(
      error,
      stackTrace: stackTrace,
      message: error.toString(),
      source: source,
      fatal: fatal,
    );
  }

  @override
  Future<void> recordBlocError(
    Object error,
    StackTrace stackTrace, {
    String? bloc,
    String? event,
  }) async {
    await _record(
      error,
      stackTrace: stackTrace,
      message: event == null ? null : 'Bloc event: $event',
      source: bloc ?? 'Bloc',
      fatal: false,
    );
  }

  Future<void> _record(
    Object error, {
    StackTrace? stackTrace,
    String? message,
    String? source,
    bool fatal = false,
    String? apiMethod,
    String? apiUrl,
    int? apiStatusCode,
    Duration? apiDuration,
    String? apiRequestBody,
    String? apiResponseBody,
  }) async {
    final DeviceSnapshot device = _deviceInfoProvider.snapshot;
    final UserContextSnapshot user = _userContextProvider.snapshot;
    final NavigationSnapshot navigation = _navigationTracker.snapshot;
    final StackTrace effectiveStackTrace = stackTrace ?? StackTrace.current;
    final ErrorReport report = ErrorReport(
      severity: fatal ? ErrorSeverity.fatal : ErrorSeverity.error,
      exceptionType: message == null
          ? error.runtimeType.toString()
          : error.runtimeType.toString(),
      exceptionMessage: redactSensitiveText(message ?? error.toString()),
      stackTrace: effectiveStackTrace.toString(),
      timestamp: DateTime.now(),
      userId: user.userId,
      userName: user.userName,
      userEmail: user.userEmail,
      currentRoute: navigation.currentRoute,
      previousRoute: navigation.previousRoute,
      navigationHistory: navigation.history,
      lastUserAction: user.lastUserAction,
      apiMethod: apiMethod,
      apiUrl: apiUrl,
      apiStatusCode: apiStatusCode,
      apiDuration: apiDuration,
      apiRequestBody: apiRequestBody,
      apiResponseBody: apiResponseBody,
      deviceModel: device.deviceModel,
      deviceManufacturer: device.manufacturer,
      deviceOsVersion: device.osVersion,
      locale: device.locale,
      appVersion: device.appVersion,
      buildNumber: device.buildNumber,
      environment: Env.environment,
      language: user.language ?? device.locale,
      subscriptionStatus: user.subscriptionStatus,
      source: source,
    );

    _logLocal(
      fatal ? 'FATAL' : 'ERROR',
      '${report.exceptionType}: ${report.exceptionMessage}',
      source: source,
      error: error,
      stackTrace: effectiveStackTrace,
      data: <String, Object?>{
        'currentRoute': navigation.currentRoute,
        'previousRoute': navigation.previousRoute,
        'apiMethod': apiMethod,
        'apiUrl': apiUrl,
        'apiStatusCode': apiStatusCode,
        'apiDurationMs': apiDuration?.inMilliseconds,
      },
    );

    await _syncCrashlyticsKeys(report: report);
    await _crashlyticsService.recordError(
      '${error.runtimeType}: ${report.exceptionMessage}',
      effectiveStackTrace,
      fatal: fatal,
      reason: source,
      information: <Object>[
        if (apiMethod != null) 'apiMethod=$apiMethod',
        if (apiUrl != null) 'apiUrl=$apiUrl',
        if (apiStatusCode != null) 'apiStatusCode=$apiStatusCode',
      ],
    );

    if (fatal || report.severity == ErrorSeverity.error) {
      unawaited(_telegramNotificationService.sendErrorReport(report));
    }
  }

  Future<void> _syncCrashlyticsKeys({ErrorReport? report}) async {
    try {
      final DeviceSnapshot device = _deviceInfoProvider.snapshot;
      final UserContextSnapshot user = _userContextProvider.snapshot;
      final NavigationSnapshot navigation = _navigationTracker.snapshot;

      await _crashlyticsService.setUserIdentifier(
        user.userId ?? 'anonymous',
      );
      await _crashlyticsService.setCustomKeys(<String, Object>{
        'current_route': navigation.currentRoute ?? 'unknown',
        'previous_route': navigation.previousRoute ?? 'unknown',
        'navigation_history': navigation.history.join(' -> '),
        'app_version': device.appVersion,
        'build_number': device.buildNumber,
        'environment': Env.environment,
        'language': user.language ?? device.locale,
        'subscription_status': user.subscriptionStatus ?? 'unknown',
        'device_model': device.deviceModel,
        'device_manufacturer': device.manufacturer,
        'device_os_version': device.osVersion,
        'locale': device.locale,
        if (user.userName != null) 'user_name': user.userName!,
        if (user.userEmail != null) 'user_email': user.userEmail!,
        if (user.lastUserAction != null) 'last_user_action': user.lastUserAction!,
        if (report != null) 'error_fingerprint': report.fingerprint,
      });
    } catch (error, stackTrace) {
      _logLocal(
        'WARNING',
        'Crashlytics key sync skipped: $error',
        source: 'AppLogger',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _logLocal(
    String level,
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    if (kReleaseMode && level == 'DEBUG') {
      return;
    }

    developer.log(
      redactSensitiveText(message),
      name: source ?? 'AppLogger',
      level: switch (level) {
        'DEBUG' => 500,
        'INFO' => 800,
        'WARNING' => 900,
        'ERROR' => 1000,
        'FATAL' => 1200,
        _ => 800,
      },
      error: error,
      stackTrace: stackTrace,
    );

    if (data != null && data.isNotEmpty && !kReleaseMode) {
      developer.log(
        data.entries
            .map((MapEntry<String, Object?> entry) => '${entry.key}=${entry.value}')
            .join(', '),
        name: source ?? 'AppLogger',
      );
    }
  }
}
