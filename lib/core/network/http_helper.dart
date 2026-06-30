import 'package:dio/dio.dart';

import '../../config/env/env.dart';

class HttpHelper {
  HttpHelper() : _dio = Dio(_baseOptions());

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
}
