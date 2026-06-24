import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/localization/localization_service.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalizationService.ensureInitialized();
  await _initializeFirebaseApp();

  // Register the top-level background message handler before runApp.
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  FirebaseMessaging.instance
      .getToken()
      .then((token) {
        if (token != null) {
          AppLogger.info('Firebase Messaging Token: $token');
        } else {
          AppLogger.error('Failed to retrieve Firebase Messaging Token.');
        }
      })
      .catchError((error, stackTrace) {
        AppLogger.error(
          'Error retrieving Firebase Messaging Token',
          error,
          stackTrace,
        );
      });

  await configureDependencies();
  runApp(LocalizationService.wrap(child: const QuraaaApp()));
}

Future<void> _initializeFirebaseApp() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully.');
  } catch (error, stackTrace) {
    AppLogger.error('Firebase initialization failed', error, stackTrace);
  }
}
