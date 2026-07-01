import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../config/env/env.dart';
import '../connectivity/connection_status.dart';
import '../connectivity/connectivity_service.dart';
import 'error_report.dart';
import 'error_report_cache.dart';

class TelegramNotificationService {
  TelegramNotificationService(
    ErrorReportCache cache,
    ConnectivityService connectivityService,
  )   : _cache = cache,
        _connectivityService = connectivityService,
        _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            contentType: Headers.formUrlEncodedContentType,
          ),
        );

  final Dio _dio;
  final ErrorReportCache _cache;
  final ConnectivityService _connectivityService;
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

    if (await _isOffline) {
      await _cache.add(report);
      return false;
    }

    await _flushCache();
    return _postReport(report);
  }

  /// Sends any reports that were stored while the device was offline.
  ///
  /// Safe to call on every app start; it exits early when there is no
  /// connectivity and clears the cache only for successfully delivered
  /// messages.
  Future<void> flushPendingReports() async {
    if (await _isOffline) {
      return;
    }
    await _flushCache();
  }

  Future<bool> _postReport(ErrorReport report) async {
    final String? token = Env.telegramBotToken?.trim();
    final String? chatId = Env.telegramChatId?.trim();

    if (token == null ||
        token.isEmpty ||
        chatId == null ||
        chatId.isEmpty) {
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

  Future<void> _flushCache() async {
    final List<ErrorReport> cachedReports = await _cache.getAll();
    if (cachedReports.isEmpty) {
      return;
    }

    for (final ErrorReport report in cachedReports) {
      if (_shouldSend(report)) {
        await _postReport(report);
      }
    }

    await _cache.clear();
  }

  Future<bool> get _isOffline async {
    final ConnectionStatus status =
        await _connectivityService.currentStatus();
    return status == ConnectionStatus.disconnected;
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
