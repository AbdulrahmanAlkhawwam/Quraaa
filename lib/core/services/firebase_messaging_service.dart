import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import '../../firebase_options.dart';
import '../constants/firebase_constants.dart';
import '../utils/logger.dart';
import 'notification_service.dart';

/// Wrapper around Firebase Cloud Messaging operations for the Quraaa app.
class FirebaseMessagingService {
  /// Creates the Firebase messaging service.
  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    required this._notificationService,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final LocalNotificationService _notificationService;

  /// Requests FCM notification permission on platforms that require it.
  Future<bool> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    AppLogger.info('FCM authorization status: ${settings.authorizationStatus}');
    return authorized;
  }

  /// Subscribes this device to the default Quraaa FCM topic.
  Future<void> subscribeToDefaultTopic() async {
    await _messaging.subscribeToTopic(FirebaseConstants.fcmTopic);
    AppLogger.info('Subscribed to FCM topic: ${FirebaseConstants.fcmTopic}');
  }

  /// Unsubscribes this device from the default Quraaa FCM topic.
  Future<void> unsubscribeFromDefaultTopic() async {
    await _messaging.unsubscribeFromTopic(FirebaseConstants.fcmTopic);
    AppLogger.info(
      'Unsubscribed from FCM topic: ${FirebaseConstants.fcmTopic}',
    );
  }

  /// Stream of foreground FCM messages.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// Returns the current device FCM token for diagnostics.
  Future<String?> getDeviceToken() => _messaging.getToken();

  /// Fetches and logs only a truncated prefix of the current FCM token.
  ///
  /// The full token is sensitive because it can be used to push notifications
  /// to this device, so it is never logged in full.
  Future<void> logDeviceToken() async {
    try {
      final token = await getDeviceToken();
      if (token != null && token.isNotEmpty) {
        final visible = token.length > 8 ? token.substring(0, 8) : token;
        AppLogger.info('Firebase Messaging Token prefix: $visible...');
      } else {
        AppLogger.error('Failed to retrieve Firebase Messaging Token.');
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error retrieving Firebase Messaging Token',
        error,
        stackTrace,
      );
    }
  }

  /// Listens to foreground messages and presents them as local notifications.
  void listenToForegroundMessages() {
    onForegroundMessage.listen((message) async {
      AppLogger.info('Foreground FCM message received: ${message.messageId}');
      await _notificationService.handleForegroundMessage(message);
    });
  }
}

/// Top-level background message handler invoked by Firebase in a separate Dart
/// isolate.
///
/// Because this runs in its own isolate, Flutter and Firebase must be
/// initialized here before any plugin call. It displays a local notification
/// using [flutter_local_notifications] directly.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Firebase invokes this callback in a separate Dart isolate, so Flutter and
  // Firebase must both be initialized here before any plugin call.
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Firebase initialization failed', error, stackTrace);
      return;
    }
  }

  // The plugin is initialized manually here because the main isolate services
  // (including the DI container) are not available in the background isolate.
  // A fresh instance is required for this Firebase background callback.
  final notificationService = LocalNotificationService();
  await notificationService.initialize(shouldRequestPermission: false);
  await notificationService.showNotificationFromRemoteMessage(message);

  AppLogger.info('Background FCM message handled: ${message.messageId}');
}
