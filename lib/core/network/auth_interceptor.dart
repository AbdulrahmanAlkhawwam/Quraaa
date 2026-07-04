import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';

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
  }) : _backendUri = Uri.parse(baseUrl);

  final AuthLocalDataSource _authLocalDataSource;
  final Uri _backendUri;

  static const String _bearerPrefix = 'Bearer';

  bool _isBackendRequest(Uri requestUri) {
    return requestUri.host == _backendUri.host &&
        requestUri.scheme == _backendUri.scheme &&
        requestUri.port == _backendUri.port;
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

    final String? accessToken = await _authLocalDataSource.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] =
          '$_bearerPrefix $accessToken';
    }

    handler.next(options);
  }
}
