import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../mappers/auth_mapper.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, Object?>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Map<String, Object?>> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  });

  Future<Map<String, Object?>> refreshToken({
    required String refreshToken,
  });

  Future<Map<String, Object?>> verifyOtp({
    required String phoneNumber,
    required String code,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<Map<String, Object?>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.login,
        data: AuthMapper.loginToJson(
          phoneNumber: phoneNumber,
          password: password,
        ),
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data.cast<String, Object?>();
      }

      throw const UnknownException(message: 'Invalid login response.');
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to login.');
    }
  }

  @override
  Future<Map<String, Object?>> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.register,
        data: AuthMapper.registerToJson(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          password: password,
          gender: gender,
          dateOfBirth: dateOfBirth,
          categoryIds: categoryIds,
        ),
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data.cast<String, Object?>();
      }

      throw const UnknownException(message: 'Invalid register response.');
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to register.');
    }
  }

  @override
  Future<Map<String, Object?>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.refreshToken,
        data: <String, Object?>{
          'refreshToken': refreshToken,
        },
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data.cast<String, Object?>();
      }

      throw const UnknownException(message: 'Invalid refresh token response.');
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to refresh session.');
    }
  }

  @override
  Future<Map<String, Object?>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.verifyOtp,
        data: AuthMapper.verifyOtpToJson(
          phoneNumber: phoneNumber,
          code: code,
        ),
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data.cast<String, Object?>();
      }

      throw const UnknownException(message: 'Invalid OTP verification response.');
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to verify OTP.');
    }
  }

  AppException _mapDioException(DioException error, String fallbackMessage) {
    final Object? underlying = error.error;
    if (underlying is AppException) {
      return underlying;
    }

    final dynamic payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      return ErrorMapper.mapResponseToException(ErrorResponseModel.fromJson(payload));
    }

    return UnknownException(message: error.message ?? fallbackMessage);
  }
}
