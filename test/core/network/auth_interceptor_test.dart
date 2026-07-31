import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/network/auth_interceptor.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
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
        ApiEndpoints.verifyOtp,
        ApiEndpoints.forgotPassword,
        ApiEndpoints.forgotPasswordVerify,
        ApiEndpoints.refreshToken,
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

      await dio.get<dynamic>('/profile/me');

      expect(
        adapter.requests.single.headers['authorization'],
        'Bearer access-token',
      );
      verify(() => authLocalDataSource.getAccessToken()).called(1);
    });
  });
}
