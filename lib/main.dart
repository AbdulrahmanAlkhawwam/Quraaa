import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/error_monitoring/app_bloc_observer.dart';
import 'core/error_monitoring/app_logger.dart';
import 'core/localization/localization_service.dart';
import 'core/localization/supported_locales.dart';
import 'core/services/app_diagnostics_service.dart';
import 'core/services/services.dart';
import 'core/services/firebase_notification_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';

RawReceivePort? _isolateErrorPort;

Future<void> main() async {
  AppLogger? appLogger;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: '.env');
      await LocalizationService.ensureInitialized();await FirebaseService.initialize();

  // Register the top-level background message handler before runApp.
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);
      await configureDependencies();

      final StorageService storageService = sl<StorageService>();
      final String? savedLanguage = storageService.getString('user_language');
      final Locale startLocale = savedLanguage == 'ar'
          ? SupportedLocales.arabic
          : SupportedLocales.english;

      appLogger = sl<AppLogger>();
      await _initializeFirebase(appLogger!);
      await appLogger!.initialize();
      await _configureErrorHandlers(appLogger!);
      await sl<AppDiagnosticsService>().logStartupSnapshot();

      // If you need a Bloc observer, set it here before runApp:
      // Bloc.observer = sl<AppBlocObserver>();

      runApp(
        LocalizationService.wrap(
          startLocale: startLocale,
          child: const QuraaaApp(),
        ),
      );
    },
    (Object error, StackTrace stackTrace) {
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

Future<void> _initializeFirebase(AppLogger appLogger) async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final NotificationService notificationService = sl<NotificationService>();
    await notificationService.initialize();
  } catch (error, stackTrace) {
    appLogger.warning(
      'Firebase initialization skipped: $error',
      source: 'main',
      data: <String, Object?>{
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      },
    );
  }
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
      final String stackTraceText =
          errorData.length > 1 ? errorData[1].toString() : '';
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
