/// Firebase and notification constants for the Quraaa app.
///
/// These values are shared between the Dart layer and the FCM payloads sent
/// from the Quraa Firebase project.
abstract final class FirebaseConstants {
  /// Default FCM topic used for broadcast notifications to all app installs.
  static const String fcmTopic = 'quraaa_users';

  /// Default notification channel ID for Android local notifications.
  static const String defaultChannelId = 'quraaa_default_channel';

  /// Default notification channel name shown to the user in Android settings.
  static const String defaultChannelName = 'Quraaa';

  /// Default notification channel description shown to the user.
  static const String defaultChannelDescription =
      'General Quraaa notifications';

  /// FCM payload key that identifies the requested action.
  static const String actionKey = 'action';

  /// FCM action value that triggers a local notification.
  static const String showNotificationAction = 'SHOW_NOTIFICATION';

  /// FCM payload key for a notification title.
  static const String titleKey = 'title';

  /// FCM payload key for a notification body.
  static const String bodyKey = 'body';
}
