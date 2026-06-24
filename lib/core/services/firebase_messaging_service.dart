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
    NotificationService? notificationService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _notificationService = notificationService ?? NotificationService();

  final FirebaseMessaging _messaging;
  final NotificationService _notificationService;

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
  Stream<RemoteMessage> get onForegroundMessage {
    return FirebaseMessaging.onMessage;
  }

  /// Returns the current device FCM token for diagnostics.
  Future<String?> getDeviceToken() {
    return _messaging.getToken();
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
  // are not available in the background isolate.
  final notificationService = NotificationService();
  await notificationService.initialize(requestPermission: false);

  final notification = message.notification;
  final data = Map<String, Object?>.from(message.data);

  final title = notification?.title ??
      data[FirebaseConstants.titleKey]?.toString() ??
      FirebaseConstants.defaultChannelName;
  final body = notification?.body ??
      data[FirebaseConstants.bodyKey]?.toString() ??
      '';

  if (body.isNotEmpty) {
    await notificationService.showNotification(title: title, body: body);
  }

  AppLogger.info('Background FCM message handled: ${message.messageId}');
}
