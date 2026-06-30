import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The app handles notification payloads from the foreground service.
}

class FirebaseNotificationService implements NotificationService {
  /// Lazily initialised so the constructor never crashes even when Firebase
  /// has not been initialised (e.g. missing google-services.json).
  FirebaseMessaging? _messaging;
  final StreamController<RemoteMessage> _foregroundMessages =
      StreamController<RemoteMessage>.broadcast();

  @override
  Stream<RemoteMessage> get foregroundMessages => _foregroundMessages.stream;

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  @override
  Future<void> initialize({bool shouldRequestPermission = true}) async {
    if (!_isFirebaseReady) {
      return;
    }
    _messaging = FirebaseMessaging.instance;
    if (shouldRequestPermission) {
      await requestPermission();
    }

    FirebaseMessaging.onMessage.listen(_foregroundMessages.add);
    FirebaseMessaging.onMessageOpenedApp.listen(_foregroundMessages.add);
  }

  @override
  Future<void> requestPermission() async {
    if (_messaging == null) return;
    await _messaging!.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    _foregroundMessages.add(message);
  }

  Future<String?> getToken() async {
    if (_messaging == null) return null;
    return _messaging!.getToken();
  }

  Future<void> dispose() async {
    await _foregroundMessages.close();
  }
}
