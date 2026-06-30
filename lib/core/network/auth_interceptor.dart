import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';

/// {@template auth_interceptor}
/// Dio interceptor that automatically attaches the stored access token to
/// outgoing requests.
///
/// The token is read from [AuthLocalDataSource] on every request so refreshed
/// tokens are picked up without recreating the [Dio] instance.
/// {@endtemplate}
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authLocalDataSource);

  final AuthLocalDataSource _authLocalDataSource;

  static const String _bearerPrefix = 'Bearer';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip if the caller already provided an authorization header.
    if (options.headers.containsKey(HttpHeaders.authorizationHeader)) {
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
