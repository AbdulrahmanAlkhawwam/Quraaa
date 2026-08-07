import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/network/auth_interceptor.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.statusCode = 200, List<int>? statusCodes})
    : _statusCodes = statusCodes ?? const <int>[];

  final int statusCode;
  final List<int> _statusCodes;
  final List<RequestOptions> requests = <RequestOptions>[];
  int _responseIndex = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final int responseStatusCode = _responseIndex < _statusCodes.length
        ? _statusCodes[_responseIndex++]
        : statusCode;
    return ResponseBody.fromString(
      '{"ok":true}',
      responseStatusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AuthInterceptor', () {
    const String baseUrl = 'https://api.quraaa.test/api';
    late _MockAuthLocalDataSource authLocalDataSource;
    late _RecordingAdapter adapter;
    late Dio dio;

    setUp(() {
      authLocalDataSource = _MockAuthLocalDataSource();
      adapter = _RecordingAdapter();
      dio = Dio(BaseOptions(baseUrl: baseUrl))
        ..interceptors.add(
          AuthInterceptor(authLocalDataSource, baseUrl: baseUrl),
        )
        ..httpClientAdapter = adapter;
    });

    tearDown(() => dio.close(force: true));

    test('does not attach a stored token to public auth endpoints', () async {
      when(
        () => authLocalDataSource.getAccessToken(),
      ).thenAnswer((_) async => 'stale-token');

      const List<String> publicPaths = <String>[
        ApiEndpoints.login,
        ApiEndpoints.register,
        ApiEndpoints.registerVerify,
        ApiEndpoints.sendOtp,
        ApiEndpoints.verifyOtp,
        ApiEndpoints.forgotPassword,
        ApiEndpoints.forgotPasswordVerify,
        ApiEndpoints.refreshToken,
        ApiEndpoints.mostPopularBooks,
      ];

      for (final String path in publicPaths) {
        await dio.post<dynamic>(path);
      }

      expect(adapter.requests, hasLength(publicPaths.length));
      for (final RequestOptions request in adapter.requests) {
        expect(request.headers, isNot(contains('authorization')));
      }
      verifyNever(() => authLocalDataSource.getAccessToken());
    });

    test('attaches the stored token to protected backend endpoints', () async {
      when(
        () => authLocalDataSource.getAccessToken(),
      ).thenAnswer((_) async => 'access-token');

      await dio.get<dynamic>(ApiEndpoints.recommendedBooks);

      expect(
        adapter.requests.single.headers['authorization'],
        'Bearer access-token',
      );
      verify(() => authLocalDataSource.getAccessToken()).called(1);
    });

    test('refreshes the token and retries the protected request once', () async {
      when(
        () => authLocalDataSource.getAccessToken(),
      ).thenAnswer((_) async => 'expired-token');
      when(
        () => authLocalDataSource.isAuthenticatedSession(),
      ).thenAnswer((_) async => true);
      var refreshCount = 0;
      var expiryNotifications = 0;

      dio.close(force: true);
      adapter = _RecordingAdapter(statusCodes: <int>[401, 200]);
      dio = Dio(BaseOptions(baseUrl: baseUrl))
        ..interceptors.add(
          AuthInterceptor(
            authLocalDataSource,
            baseUrl: baseUrl,
            onRefreshSession: () async {
              refreshCount++;
              return 'fresh-token';
            },
            onRetryRequest: (RequestOptions options) =>
                dio.fetch<dynamic>(options),
            onSessionExpired: () async {
              expiryNotifications++;
            },
          ),
        )
        ..httpClientAdapter = adapter;

      final Response<dynamic> response =
          await dio.get<dynamic>(ApiEndpoints.recommendedBooks);

      expect(response.statusCode, 200);
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.last.headers['authorization'],
        'Bearer fresh-token',
      );
      expect(refreshCount, 1);
      expect(expiryNotifications, 0);
    });

    test('notifies when refreshing an authenticated session fails', () async {
      when(
        () => authLocalDataSource.getAccessToken(),
      ).thenAnswer((_) async => 'expired-token');
      when(
        () => authLocalDataSource.isAuthenticatedSession(),
      ).thenAnswer((_) async => true);
      var expiryNotifications = 0;

      dio.close(force: true);
      adapter = _RecordingAdapter(statusCode: 401);
      dio = Dio(BaseOptions(baseUrl: baseUrl))
        ..interceptors.add(
          AuthInterceptor(
            authLocalDataSource,
            baseUrl: baseUrl,
            onRefreshSession: () async => null,
            onSessionExpired: () async {
              expiryNotifications++;
            },
          ),
        )
        ..httpClientAdapter = adapter;

      await expectLater(
        dio.get<dynamic>(ApiEndpoints.recommendedBooks),
        throwsA(isA<DioException>()),
      );

      expect(expiryNotifications, 1);
    });
  });
}
