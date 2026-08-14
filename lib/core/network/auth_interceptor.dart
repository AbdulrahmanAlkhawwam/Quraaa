import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../constants/api_endpoints.dart';

/// Called after an authenticated backend request proves that the session is no
/// longer accepted by the server.
typedef SessionExpiredCallback = Future<void> Function();

/// Refreshes the session and returns the new access token on success.
typedef RefreshSessionCallback = Future<String?> Function();

/// Repeats a request after the access token has been refreshed.
typedef RetryRequestCallback = Future<Response<dynamic>> Function(
  RequestOptions options,
);

/// {@template auth_interceptor}
/// Attaches the stored access token, refreshes an expired session once, and
/// retries the failed backend request with the new token.
///
/// The token is read from [AuthLocalDataSource] on every request so refreshed
/// tokens are picked up without recreating the [Dio] instance.
///
/// [baseUrl] is the backend base URL (scheme + host, optional port). The
/// interceptor only attaches the token when the request URI matches this host,
/// preventing accidental leakage to third-party URLs.
/// {@endtemplate}
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._authLocalDataSource, {
    required String baseUrl,
    SessionExpiredCallback? onSessionExpired,
    RefreshSessionCallback? onRefreshSession,
    RetryRequestCallback? onRetryRequest,
  }) : _backendUri = Uri.parse(baseUrl),
       _onSessionExpired = onSessionExpired,
       _onRefreshSession = onRefreshSession,
       _onRetryRequest = onRetryRequest;

  final AuthLocalDataSource _authLocalDataSource;
  final SessionExpiredCallback? _onSessionExpired;
  final RefreshSessionCallback? _onRefreshSession;
  final RetryRequestCallback? _onRetryRequest;
  final Uri _backendUri;

  Future<String?>? _refreshInFlight;
  bool _handlingExpiredSession = false;

  static const String _bearerPrefix = 'Bearer';
  static const String _retryAttemptedKey = 'auth_retry_attempted';
  static const Set<String> _publicAuthPaths = <String>{
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.registerVerify,
    ApiEndpoints.sendOtp,
    ApiEndpoints.verifyOtp,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.forgotPasswordVerify,
    ApiEndpoints.refreshToken,
    ApiEndpoints.mostPopularBooks,
  };

  bool _isBackendRequest(Uri requestUri) {
    return requestUri.host == _backendUri.host &&
        requestUri.scheme == _backendUri.scheme &&
        requestUri.port == _backendUri.port;
  }

  bool _isPublicAuthRequest(RequestOptions options) {
    return _publicAuthPaths.contains(Uri.parse(options.path).path);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip if the caller already provided an authorization header.
    if (options.headers.containsKey(HttpHeaders.authorizationHeader)) {
      return handler.next(options);
    }

    // Never attach auth tokens to non-backend requests.
    if (!_isBackendRequest(options.uri)) {
      return handler.next(options);
    }

    // Public authentication endpoints must not inherit a stale session token.
    if (_isPublicAuthRequest(options)) {
      return handler.next(options);
    }

    final String? accessToken = await _authLocalDataSource.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] =
          '$_bearerPrefix $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = error.requestOptions;
    final bool isExpiredSessionResponse =
        error.response?.statusCode == HttpStatus.unauthorized &&
        _isBackendRequest(options.uri) &&
        !_isPublicAuthRequest(options);

    if (!isExpiredSessionResponse || _handlingExpiredSession) {
      handler.next(error);
      return;
    }

    // A retried request is never refreshed again, which prevents a 401 loop.
    if (options.extra[_retryAttemptedKey] == true) {
      handler.next(error);
      return;
    }

    final bool wasAuthenticated =
        await _authLocalDataSource.isAuthenticatedSession();
    if (!wasAuthenticated) {
      handler.next(error);
      return;
    }

    final String? latestAccessToken =
        await _authLocalDataSource.getAccessToken();
    final String failedAuthorization =
        options.headers[HttpHeaders.authorizationHeader]?.toString() ?? '';

    // Another failed request may already have refreshed the token. Reuse that
    // token instead of starting a second refresh request.
    String? accessToken;
    if (latestAccessToken != null &&
        latestAccessToken.isNotEmpty &&
        failedAuthorization != '$_bearerPrefix $latestAccessToken') {
      accessToken = latestAccessToken;
    } else {
      accessToken = await _refreshAccessToken();
    }

    DioException failureToForward = error;
    final RetryRequestCallback? retryRequest = _onRetryRequest;
    if (accessToken != null &&
        accessToken.isNotEmpty &&
        retryRequest != null) {
      options.headers[HttpHeaders.authorizationHeader] =
          '$_bearerPrefix $accessToken';
      options.extra[_retryAttemptedKey] = true;

      try {
        final Response<dynamic> response = await retryRequest(options);
        handler.resolve(response);
        return;
      } on DioException catch (retryError) {
        failureToForward = retryError;
        if (retryError.response?.statusCode != HttpStatus.unauthorized) {
          handler.next(retryError);
          return;
        }
      } catch (retryError) {
        handler.next(
          DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            error: retryError,
          ),
        );
        return;
      }
    }

    await _expireSession();
    handler.next(failureToForward);
  }

  Future<String?> _refreshAccessToken() async {
    final Future<String?> refresh =
        _refreshInFlight ??= _runRefreshSafely();
    try {
      return await refresh;
    } finally {
      if (identical(_refreshInFlight, refresh)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<String?> _runRefreshSafely() async {
    try {
      return await _onRefreshSession?.call();
    } catch (_) {
      return null;
    }
  }

  Future<void> _expireSession() async {
    if (_handlingExpiredSession) {
      return;
    }
    _handlingExpiredSession = true;
    try {
      await _onSessionExpired?.call();
    } finally {
      _handlingExpiredSession = false;
    }
  }
}
