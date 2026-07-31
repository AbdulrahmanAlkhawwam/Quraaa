import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/app_storage_keys.dart';
import 'package:quraaa/core/network/language_interceptor.dart';
import 'package:quraaa/core/services/storage_service.dart';

class _MockStorageService extends Mock implements StorageService {}

class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('attaches the selected app language to every request', () async {
    final _MockStorageService storage = _MockStorageService();
    final _RecordingAdapter adapter = _RecordingAdapter();
    when(() => storage.getString(AppStorageKeys.userLanguage)).thenReturn('ar');
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.quraaa.test'))
      ..interceptors.add(LanguageInterceptor(storage))
      ..httpClientAdapter = adapter;

    await dio.get<dynamic>('/books');

    expect(adapter.request?.headers['Accept-Language'], 'ar');
    dio.close(force: true);
  });

  test('does not overwrite an explicitly provided language header', () async {
    final _MockStorageService storage = _MockStorageService();
    final _RecordingAdapter adapter = _RecordingAdapter();
    when(() => storage.getString(AppStorageKeys.userLanguage)).thenReturn('ar');
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.quraaa.test'))
      ..interceptors.add(LanguageInterceptor(storage))
      ..httpClientAdapter = adapter;

    await dio.get<dynamic>(
      '/books',
      options: Options(headers: <String, dynamic>{'Accept-Language': 'en'}),
    );

    expect(adapter.request?.headers['Accept-Language'], 'en');
    dio.close(force: true);
  });
}
