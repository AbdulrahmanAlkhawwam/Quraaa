import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../config/env/env.dart';
import 'error_report.dart';

class TelegramNotificationService {
  TelegramNotificationService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            contentType: Headers.formUrlEncodedContentType,
          ),
        );

  final Dio _dio;
  final Map<String, DateTime> _recentFingerprintHits = <String, DateTime>{};

  Future<bool> sendErrorReport(ErrorReport report) async {
    final String? token = Env.telegramBotToken?.trim();
    final String? chatId = Env.telegramChatId?.trim();

    if (token == null ||
        token.isEmpty ||
        chatId == null ||
        chatId.isEmpty) {
      return false;
    }

    if (!_shouldSend(report)) {
      return false;
    }

    try {
      await _dio.post<dynamic>(
        'https://api.telegram.org/bot$token/sendMessage',
        data: <String, Object?>{
          'chat_id': chatId,
          'text': report.toTelegramMessage(),
          'disable_web_page_preview': true,
        },
      );
      return true;
    } catch (error, stackTrace) {
      developer.log(
        'Telegram notification failed: $error',
        name: 'TelegramNotificationService',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  bool _shouldSend(ErrorReport report) {
    final DateTime now = DateTime.now();
    _cleanupExpiredEntries(now);

    final DateTime? lastSent = _recentFingerprintHits[report.fingerprint];
    if (lastSent != null && now.difference(lastSent) < const Duration(minutes: 10)) {
      return false;
    }

    _recentFingerprintHits[report.fingerprint] = now;
    return true;
  }

  void _cleanupExpiredEntries(DateTime now) {
    _recentFingerprintHits.removeWhere(
      (String _, DateTime timestamp) =>
          now.difference(timestamp) > const Duration(minutes: 10),
    );
  }
}
