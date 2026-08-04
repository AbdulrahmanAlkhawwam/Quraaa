import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../connectivity/connection_status.dart';
import '../connectivity/connectivity_service.dart';
import 'error_report.dart';
import 'error_report_cache.dart';

/// {@template telegram_notification_service}
/// Sends error reports to the configured Telegram recipients.
///
/// The bot token and primary chat ID are supplied via constructor. A copy is
/// also sent to the project owner. The app no longer reads these values from
/// the bundled `.env` file because that would ship secrets inside the app
/// package. If the bot token is missing, reporting is silently disabled.
///
/// In the long term this should be replaced by a backend endpoint that holds
/// the token server-side.
/// {@endtemplate}
class TelegramNotificationService {
  TelegramNotificationService(
    this._cache,
    this._connectivityService, {
    this._botToken,
    this._chatId,
  }) : _dio = Dio(
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
  final String? _botToken;
  final String? _chatId;
  final Map<String, DateTime> _recentFingerprintHits = <String, DateTime>{};

  /// Receives a copy in addition to the primary recipient configured at build
  /// time. Telegram chat IDs are not bot credentials, but this value should
  /// still be kept limited to the intended error-report recipients.
  static const String _ownerChatId = '938273731';

  Future<bool> sendErrorReport(ErrorReport report) async {
    final String? token = _botToken?.trim();
    final Set<String> chatIds = _recipientChatIds;

    if (token == null || token.isEmpty || chatIds.isEmpty) {
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
    final String? token = _botToken?.trim();
    final Set<String> chatIds = _recipientChatIds;

    if (token == null || token.isEmpty || chatIds.isEmpty) {
      return false;
    }

    var sentToAllRecipients = true;
    for (final String chatId in chatIds) {
      try {
        await _dio.post<dynamic>(
          'https://api.telegram.org/bot$token/sendMessage',
          data: <String, Object?>{
            'chat_id': chatId,
            'text': report.toTelegramMessage(),
            'disable_web_page_preview': true,
          },
        );
      } catch (error, stackTrace) {
        sentToAllRecipients = false;
        developer.log(
          'Telegram notification failed for chat $chatId: $error',
          name: 'TelegramNotificationService',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return sentToAllRecipients;
  }

  Set<String> get _recipientChatIds => <String>{
    if (_chatId?.trim().isNotEmpty ?? false) _chatId!.trim(),
    _ownerChatId,
  };

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
    if (lastSent != null &&
        now.difference(lastSent) < const Duration(minutes: 10)) {
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
