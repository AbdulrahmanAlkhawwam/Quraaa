import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_codes.dart';
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

  Future<Map<String, Object?>> refreshToken({required String refreshToken});

  Future<Map<String, Object?>> verifyOtp({
    required String phoneNumber,
    required String code,
  });

  Future<void> forgotPassword({required String phoneNumber});

  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
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
      throw _mapDioException(
        error,
        'Unable to login.',
        unauthorizedFallbackCode: ErrorCodes.loginFailed,
      );
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
      final AppException mapped = _mapDioException(
        error,
        'Unable to register.',
      );
      if (_requiresOtpVerification(error.response?.data, mapped)) {
        throw OtpVerificationRequiredException(message: mapped.message);
      }
      throw mapped;
    }
  }

  @override
  Future<Map<String, Object?>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.refreshToken,
        data: <String, Object?>{'refreshToken': refreshToken},
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data.cast<String, Object?>();
      }

      throw const UnknownException(message: 'Invalid refresh token response.');
    } on DioException catch (error) {
      throw _mapDioException(
        error,
        'Unable to refresh session.',
        unauthorizedFallbackCode: ErrorCodes.tokenExpired,
      );
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
        data: AuthMapper.verifyOtpToJson(phoneNumber: phoneNumber, code: code),
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data.cast<String, Object?>();
      }

      throw const UnknownException(
        message: 'Invalid OTP verification response.',
      );
    } on DioException catch (error) {
      throw _mapDioException(
        error,
        'Unable to verify OTP.',
        unauthorizedFallbackCode: ErrorCodes.invalidVerificationCode,
      );
    }
  }

  @override
  Future<void> forgotPassword({required String phoneNumber}) async {
    try {
      await _httpHelper.post(
        ApiEndpoints.forgotPassword,
        data: AuthMapper.forgotPasswordToJson(phoneNumber: phoneNumber),
      );
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to request password reset.');
    }
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _httpHelper.post(
        ApiEndpoints.forgotPasswordVerify,
        data: AuthMapper.resetPasswordToJson(
          phoneNumber: phoneNumber,
          code: code,
          newPassword: newPassword,
        ),
      );
    } on DioException catch (error) {
      throw _mapDioException(
        error,
        'Unable to reset password.',
        unauthorizedFallbackCode: ErrorCodes.invalidVerificationCode,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _httpHelper.post(
        ApiEndpoints.changePassword,
        data: AuthMapper.changePasswordToJson(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ),
      );
    } on DioException catch (error) {
      throw _mapDioException(error, 'Unable to change password.');
    }
  }

  bool _requiresOtpVerification(dynamic payload, AppException mapped) {
    final String responseCode = payload is Map
        ? (payload['code'] ?? payload['type'] ?? '').toString()
        : '';
    final Set<String> codes = <String>{
      mapped.code,
      responseCode,
    }.map((String value) => value.toLowerCase().replaceAll('-', '_')).toSet();
    const Set<String> verificationCodes = <String>{
      ErrorCodes.otpVerificationRequired,
      'pending_verification',
      'phone_verification_required',
      'phone_number_not_verified',
      'user_not_verified',
      'account_not_verified',
      'unverified_user',
    };
    if (codes.any(verificationCodes.contains)) {
      return true;
    }

    final String text = <String>[
      mapped.message,
      _flattenErrorPayload(payload),
    ].join(' ').toLowerCase().replaceAll(RegExp('[_-]+'), ' ');
    final bool mentionsVerification =
        text.contains('otp') ||
        text.contains('verification') ||
        text.contains('verify') ||
        text.contains('not verified') ||
        text.contains('unverified');
    final bool mentionsPendingAccount =
        text.contains('pending') ||
        text.contains('awaiting') ||
        text.contains('not verified') ||
        text.contains('unverified') ||
        text.contains('already registered') ||
        text.contains('already exists');
    return mentionsVerification && mentionsPendingAccount;
  }

  String _flattenErrorPayload(dynamic value) {
    if (value == null) return '';
    if (value is String || value is num || value is bool) {
      return value.toString();
    }
    if (value is Iterable) {
      return value.map(_flattenErrorPayload).join(' ');
    }
    if (value is Map) {
      return value.entries
          .map(
            (MapEntry<dynamic, dynamic> entry) =>
                '${entry.key} ${_flattenErrorPayload(entry.value)}',
          )
          .join(' ');
    }
    return '';
  }

  AppException _mapDioException(
    DioException error,
    String fallbackMessage, {
    String? unauthorizedFallbackCode,
  }) {
    final Object? underlying = error.error;
    if (underlying is AppException) {
      return underlying;
    }

    final dynamic payload = error.response?.data;
    if (payload is Map) {
      final Map<String, dynamic> responseJson = Map<String, dynamic>.from(
        payload,
      );
      _addUnauthorizedFallbackCode(
        responseJson,
        error.response?.statusCode,
        unauthorizedFallbackCode,
      );
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(
          responseJson,
          statusCode: error.response?.statusCode,
        ),
      );
    }
    if (payload is String && payload.trim().isNotEmpty) {
      final Map<String, dynamic> responseJson = <String, dynamic>{
        'message': payload.trim(),
      };
      _addUnauthorizedFallbackCode(
        responseJson,
        error.response?.statusCode,
        unauthorizedFallbackCode,
      );
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(
          responseJson,
          statusCode: error.response?.statusCode,
        ),
      );
    }

    final int? statusCode = error.response?.statusCode;
    if (statusCode != null) {
      final Map<String, dynamic> responseJson = <String, dynamic>{};
      _addUnauthorizedFallbackCode(
        responseJson,
        statusCode,
        unauthorizedFallbackCode,
      );
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(responseJson, statusCode: statusCode),
      );
    }

    return switch (error.type) {
      DioExceptionType.cancel => const OperationCancelledException(),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => const NetworkException(),
      _ => UnknownException(message: fallbackMessage),
    };
  }

  void _addUnauthorizedFallbackCode(
    Map<String, dynamic> responseJson,
    int? statusCode,
    String? unauthorizedFallbackCode,
  ) {
    if (statusCode == 401 &&
        unauthorizedFallbackCode != null &&
        !responseJson.containsKey('code')) {
      responseJson['code'] = unauthorizedFallbackCode;
    }
  }
}
