import 'dart:async';

import 'package:dio/dio.dart';

import 'app_logger.dart';
import 'error_report.dart';

class DioLoggingInterceptor extends Interceptor {
  DioLoggingInterceptor(this._logger);

  final AppLogger _logger;

  static const String _startedAtKey = 'monitoring_started_at';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra[_startedAtKey] = DateTime.now().millisecondsSinceEpoch;
    _logger.recordUserAction(
      'HTTP ${options.method} ${options.uri}',
      source: 'dio',
    );
    _logger.debug(
      'HTTP request ${options.method} ${options.uri}',
      source: 'dio',
      data: <String, Object?>{
        'method': options.method,
        'url': options.uri.toString(),
        'requestBody': encodeSanitizedBody(options.data),
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final Duration duration = _duration(response.requestOptions);
    _logger.debug(
      'HTTP response ${response.statusCode} ${response.requestOptions.uri}',
      source: 'dio',
      data: <String, Object?>{
        'method': response.requestOptions.method,
        'url': response.requestOptions.uri.toString(),
        'statusCode': response.statusCode,
        'durationMs': duration.inMilliseconds,
        'responseBody': truncateBody(encodeSanitizedBody(response.data)),
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Duration duration = _duration(err.requestOptions);
    final ErrorSeverity severity =
        err.type == DioExceptionType.cancel ? ErrorSeverity.warning : ErrorSeverity.error;

    if (severity == ErrorSeverity.warning) {
      _logger.warning(
        'HTTP request cancelled: ${err.requestOptions.method} ${err.requestOptions.uri}',
        source: 'dio',
      );
      handler.next(err);
      return;
    }

    unawaited(
      _logger.error(
        err,
        stackTrace: err.stackTrace ?? StackTrace.current,
        source: 'dio',
        message: err.message ?? 'Request failed.',
        apiMethod: err.requestOptions.method,
        apiUrl: err.requestOptions.uri.toString(),
        apiStatusCode: err.response?.statusCode,
        apiDuration: duration,
        apiRequestBody: truncateBody(encodeSanitizedBody(err.requestOptions.data)),
        apiResponseBody: truncateBody(encodeSanitizedBody(err.response?.data)),
      ),
    );
    handler.next(err);
  }

  Duration _duration(RequestOptions options) {
    final int? startedAt = options.extra[_startedAtKey] as int?;
    if (startedAt == null) {
      return Duration.zero;
    }

    return DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(startedAt),
    );
  }
}
