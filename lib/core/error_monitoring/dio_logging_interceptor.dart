import 'dart:async';

import 'package:dio/dio.dart';

import 'app_logger.dart';
import 'error_report.dart';

class DioLoggingInterceptor extends Interceptor {
  DioLoggingInterceptor(this._logger);

  final AppLogger _logger;

  static const String _startedAtKey = 'monitoring_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
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
        'requestBody': _encodeRequestBody(options.data),
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
    final ErrorSeverity severity = err.type == DioExceptionType.cancel
        ? ErrorSeverity.warning
        : ErrorSeverity.error;

    if (severity == ErrorSeverity.warning) {
      _logger.warning(
        'HTTP request cancelled: ${err.requestOptions.method} ${err.requestOptions.uri}',
        source: 'dio',
      );
      handler.next(err);
      return;
    }

    final String requestBody = truncateBody(
      _encodeRequestBody(err.requestOptions.data),
    );
    final String requestHeaders = truncateBody(
      encodeSanitizedBody(err.requestOptions.headers),
      maxLength: 800,
    );
    final String responseHeaders = truncateBody(
      encodeSanitizedBody(err.response?.headers.map),
      maxLength: 800,
    );
    final String responseBody = truncateBody(
      encodeSanitizedBody(err.response?.data),
    );

    // Keep actionable HTTP details next to the Dio error in debug logs.
    // Sensitive header/body values are redacted by encodeSanitizedBody.
    _logger.warning(
      'HTTP failure details: ${err.requestOptions.method} '
      '${err.requestOptions.uri}',
      source: 'dio',
      data: <String, Object?>{
        'statusCode': err.response?.statusCode,
        'requestHeaders': requestHeaders,
        'requestBody': requestBody,
        'responseHeaders': responseHeaders,
        'responseBody': responseBody,
      },
    );

    final int? statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      handler.next(err);
      return;
    }
    unawaited(
      _logger.error(
        err,
        stackTrace: err.stackTrace,
        source: 'dio',
        message: err.message ?? 'Request failed.',
        apiMethod: err.requestOptions.method,
        apiUrl: err.requestOptions.uri.toString(),
        apiStatusCode: err.response?.statusCode,
        apiDuration: duration,
        apiRequestHeaders: requestHeaders,
        apiRequestBody: requestBody,
        apiResponseHeaders: responseHeaders,
        apiResponseBody: responseBody,
      ),
    );
    handler.next(err);
  }

  String _encodeRequestBody(Object? data) {
    if (data is FormData) {
      return encodeSanitizedBody(<String, Object?>{
        'fields': <String, String>{
          for (final MapEntry<String, String> field in data.fields)
            field.key: field.value,
        },
        'files': data.files
            .map(
              (MapEntry<String, MultipartFile> file) => <String, Object?>{
                'field': file.key,
                'filename': file.value.filename,
                'length': file.value.length,
              },
            )
            .toList(growable: false),
      });
    }
    return encodeSanitizedBody(data);
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
