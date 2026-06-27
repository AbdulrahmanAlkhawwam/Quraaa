import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/firebase_constants.dart';
import '../utils/logger.dart';

/// Handles local notification display and FCM message presentation for the
/// Quraaa app.
///
/// Uses [flutter_local_notifications] so notifications work on Android and
/// iOS without relying on the custom native plugin from quraa_otp.
class NotificationService {
  /// Creates the notification service.
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  static int _notificationId = 0;

  /// Initializes the plugin, creates the default Android notification channel,
  /// and optionally requests notification permission.
  Future<void> initialize({bool requestPermission = true}) async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Darwin settings cover iOS and macOS. Permission is requested through
    // [requestNotificationPermission] to keep a single cross-platform entry
    // point, so alert/badge/sound request flags are disabled here.
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createDefaultChannel();

    if (requestPermission) {
      await requestNotificationPermission();
    }

    _initialized = true;
  }

  /// Requests the notification permission on platforms that require a runtime
  /// request (Android 13+ and iOS).
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    AppLogger.info('Permission.notification status: ${status.name}');
    return status.isGranted;
  }

  /// Displays a local notification with the supplied [title] and [body].
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize(requestPermission: false);

    final androidDetails = AndroidNotificationDetails(
      FirebaseConstants.defaultChannelId,
      FirebaseConstants.defaultChannelName,
      channelDescription: FirebaseConstants.defaultChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      _nextNotificationId(),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Convenience helper for simple message notifications.
  Future<void> showMessage(String message) async {
    await showNotification(
      title: FirebaseConstants.defaultChannelName,
      body: message,
    );
  }

  /// Handles an incoming foreground FCM message by presenting a local
  /// notification when the payload contains a body.
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    await showNotificationFromRemoteMessage(message);
  }

  /// Parses an FCM message and displays it as a local notification when a body
  /// is available.
  Future<void> showNotificationFromRemoteMessage(RemoteMessage message) async {
    final data = Map<String, Object?>.from(message.data);
    final notification = message.notification;

    final title =
        notification?.title ??
        data[FirebaseConstants.titleKey]?.toString() ??
        FirebaseConstants.defaultChannelName;
    final body =
        notification?.body ?? data[FirebaseConstants.bodyKey]?.toString() ?? '';

    if (body.isEmpty) {
      AppLogger.info('FCM message has no body; skipping local notification.');
      return;
    }

    await showNotification(title: title, body: body);
  }

  /// Reads notification details that launched the app from a terminated state.
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  int _nextNotificationId() {
    _notificationId = (_notificationId + 1) & 0x7FFFFFFF;
    return _notificationId;
  }

  Future<void> _createDefaultChannel() async {
    const channel = AndroidNotificationChannel(
      FirebaseConstants.defaultChannelId,
      FirebaseConstants.defaultChannelName,
      description: FirebaseConstants.defaultChannelDescription,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
    // TODO: Navigate to the relevant screen based on payload.
  }
}
