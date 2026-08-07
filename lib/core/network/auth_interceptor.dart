import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../constants/api_endpoints.dart';

/// Called after an authenticated backend request proves that the session is no
/// longer accepted by the server.
typedef SessionExpiredCallback = Future<void> Function();

/// {@template auth_interceptor}
/// Dio interceptor that automatically attaches the stored access token to
/// outgoing requests that target the app's backend.
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
  }) : _backendUri = Uri.parse(baseUrl),
       _onSessionExpired = onSessionExpired;

  final AuthLocalDataSource _authLocalDataSource;
  final SessionExpiredCallback? _onSessionExpired;
  final Uri _backendUri;
  bool _handlingExpiredSession = false;

  static const String _bearerPrefix = 'Bearer';
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

    final bool wasAuthenticated =
        await _authLocalDataSource.isAuthenticatedSession();
    if (!wasAuthenticated) {
      handler.next(error);
      return;
    }

    _handlingExpiredSession = true;
    try {
      await _onSessionExpired?.call();
    } finally {
      _handlingExpiredSession = false;
    }

    handler.next(error);
  }
}
