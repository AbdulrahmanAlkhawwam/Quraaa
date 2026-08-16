import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/constants/app_storage_keys.dart';
import 'core/error_monitoring/app_logger.dart';
import 'core/error_monitoring/telegram_notification_service.dart';
import 'core/localization/localization_service.dart';
import 'core/localization/supported_locales.dart';
import 'core/services/app_diagnostics_service.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';

RawReceivePort? _isolateErrorPort;

Future<void> main() async {
  AppLogger? appLogger;

  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await LocalizationService.ensureInitialized();

        // Register the top-level background message handler before runApp.
        FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

        await configureDependencies();

        final StorageService storageService = sl<StorageService>();
        final Locale startLocale = SupportedLocales.fromCode(
          storageService.getString(AppStorageKeys.userLanguage),
        );

        appLogger = sl<AppLogger>();
        await appLogger!.initialize();
        await _configureErrorHandlers(appLogger!);

        runApp(
          LocalizationService.wrap(
            startLocale: startLocale,
            child: const QuraaaApp(),
          ),
        );
        unawaited(_initializeOptionalServices(appLogger!));
      } catch (error, stackTrace) {
        debugPrint('Quraaa startup failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (appLogger != null) {
          unawaited(
            appLogger!.recordAsyncError(
              error,
              stackTrace,
              source: 'startup',
              fatal: true,
            ),
          );
        }
        runApp(_StartupFailureApp(error: error));
      }
    },
    (Object error, StackTrace stackTrace) {
      debugPrint('Unhandled Quraaa error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (appLogger != null) {
        unawaited(
          appLogger!.recordAsyncError(
            error,
            stackTrace,
            source: 'runZonedGuarded',
            fatal: true,
          ),
        );
      }
    },
  );
}

Future<void> _initializeOptionalServices(AppLogger appLogger) async {
  await FirebaseService.initialize();

  try {
    await initializeNotificationDependencies();
  } catch (error, stackTrace) {
    appLogger.warning(
      'Notification initialization skipped: $error',
      source: 'main',
      data: <String, Object?>{
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      },
    );
  }

  try {
    await sl<TelegramNotificationService>().flushPendingReports();
  } catch (error, stackTrace) {
    appLogger.warning(
      'Pending error report flush skipped: $error',
      source: 'main',
      data: <String, Object?>{
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      },
    );
  }

  await sl<AppDiagnosticsService>().logStartupSnapshot();
}

Future<void> _configureErrorHandlers(AppLogger appLogger) async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    unawaited(appLogger.recordFlutterError(details));
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    unawaited(appLogger.recordPlatformDispatcherError(error, stackTrace));
    return true;
  };

  _isolateErrorPort = RawReceivePort((dynamic errorData) {
    if (errorData is List<dynamic> && errorData.isNotEmpty) {
      final Object error = errorData.first as Object;
      final String stackTraceText = errorData.length > 1
          ? errorData[1].toString()
          : '';
      unawaited(
        appLogger.recordAsyncError(
          error,
          StackTrace.fromString(stackTraceText),
          source: 'Isolate',
          fatal: true,
        ),
      );
    }
  });
  Isolate.current.addErrorListener(_isolateErrorPort!.sendPort);
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF4FBEF),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 52,
                    color: Color(0xFF4FAF32),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Unable to start the app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF173D19),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Close the app and open it again. If the problem continues, send the launch log to support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF60705E)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.runtimeType.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF899486),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
