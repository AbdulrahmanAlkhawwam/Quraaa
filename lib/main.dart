import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/localization/localization_service.dart';
import 'core/services/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalizationService.ensureInitialized();
  await FirebaseService.initialize();

  // Register the top-level background message handler before runApp.
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  await configureDependencies();
  runApp(LocalizationService.wrap(child: const QuraaaApp()));
}
