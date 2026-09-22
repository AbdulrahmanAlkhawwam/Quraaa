/// Third-party hosts the app talks to directly. Paths on our own backend
/// belong in `ApiEndpoints`, and the backend host in `AppConfig`.
abstract class ExternalUrls {
  ExternalUrls._();

  static const String openStreetMapTiles =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static String telegramSendMessage(String botToken) =>
      'https://api.telegram.org/bot$botToken/sendMessage';
}
