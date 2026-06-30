import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/services/app_diagnostics_service.dart';
import 'core/localization/localization_service.dart';
import 'core/services/services.dart';
import 'core/services/firebase_notification_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await LocalizationService.ensureInitialized();
  await FirebaseService.initialize();

  // Register the top-level background message handler before runApp.
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  await configureDependencies();
  await const AppDiagnosticsService().logStartupSnapshot();
  await _initializeFirebaseMessaging();
  runApp(LocalizationService.wrap(child: const QuraaaApp()));
}

Future<void> _initializeFirebaseMessaging() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final NotificationService notificationService =
        sl<NotificationService>();
    await notificationService.initialize();
  } catch (error) {
    // Firebase configuration is optional during local development; the app still runs.
    debugPrint('Firebase initialization skipped: $error');
  }
}
