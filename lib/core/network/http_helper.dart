import 'package:dio/dio.dart';

import '../../config/env/env.dart';

class HttpHelper {
  HttpHelper(this._dio);

  final Dio _dio;

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: <String, Object?>{
        Headers.acceptHeader: 'application/json',
        Headers.contentTypeHeader: 'application/json',
      },
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.post<dynamic>(
      path,
      data: data,
      options: options,
    );
  }

  static Dio buildDio(List<Interceptor> interceptors) {
    return Dio(_baseOptions())..interceptors.addAll(interceptors);
  }
}
