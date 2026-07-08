import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/connectivity/connectivity_service.dart';
import 'package:quraaa/core/connectivity/connection_status.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/connectivity_interceptor.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

class _MockAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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
  group('ConnectivityInterceptor', () {
    late MockConnectivityService connectivityService;
    late Dio dio;

    setUp(() {
      connectivityService = MockConnectivityService();
      dio = Dio(
        BaseOptions(baseUrl: 'https://api.quraaa.test'),
      )
        ..interceptors.add(ConnectivityInterceptor(connectivityService))
        ..httpClientAdapter = _MockAdapter();
    });

    tearDown(() {
      dio.close(force: true);
    });

    test('rejects the request when the device is offline', () async {
      when(() => connectivityService.currentStatus())
          .thenAnswer((_) async => ConnectionStatus.disconnected);

      await expectLater(
        () => dio.get<dynamic>('/test'),
        throwsA(
          isA<DioException>()
              .having(
                (e) => e.type,
                'type',
                DioExceptionType.connectionError,
              )
              .having(
                (e) => e.error,
                'error',
                isA<NoInternetException>(),
              ),
        ),
      );

      verify(() => connectivityService.currentStatus()).called(1);
    });

    test('allows the request when the device is online', () async {
      when(() => connectivityService.currentStatus())
          .thenAnswer((_) async => ConnectionStatus.connected);

      final Response<dynamic> response = await dio.get<dynamic>('/test');

      expect(response.statusCode, 200);
      verify(() => connectivityService.currentStatus()).called(1);
    });
  });
}
