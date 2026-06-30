import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The app handles notification payloads from the foreground service.
}

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService() : _messaging = FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final StreamController<RemoteMessage> _foregroundMessages =
      StreamController<RemoteMessage>.broadcast();

  @override
  Stream<RemoteMessage> get foregroundMessages => _foregroundMessages.stream;

  @override
  Future<void> initialize() async {
    await requestPermission();

    FirebaseMessaging.onMessage.listen(_foregroundMessages.add);
    FirebaseMessaging.onMessageOpenedApp.listen(_foregroundMessages.add);
  }

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Future<void> dispose() async {
    await _foregroundMessages.close();
  }
}
