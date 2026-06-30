import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static const String appName = 'Quraaa';
  static String get environment =>
      dotenv.maybeGet('APP_ENV') ?? (kReleaseMode ? 'production' : 'development');

  static bool get isDev =>
      environment == 'dev' || environment == 'development';

  static String get host => dotenv.maybeGet('HOST') ?? '127.0.0.1:8080';

  static String get baseUrl => dotenv.maybeGet('BASEURL') ?? 'api';

  static String get apiBaseUrl {
    final String normalizedHost =
        host.startsWith('http://') || host.startsWith('https://')
            ? host
            : 'http://$host';
    return '$normalizedHost/$baseUrl';
  }

  static String? get latestVersion => dotenv.maybeGet('LATEST_VERSION');

  static String? get telegramBotToken => dotenv.maybeGet('TELEGRAM_BOT_TOKEN');

  static String? get telegramChatId => dotenv.maybeGet('TELEGRAM_CHAT_ID');
}
