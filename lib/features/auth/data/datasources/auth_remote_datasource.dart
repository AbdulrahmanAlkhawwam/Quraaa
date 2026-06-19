import 'package:dio/dio.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/network/http_helper.dart';
import '../mappers/auth_mapper.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, Object?>> login({
    required String username,
    required String password,
  });

  Future<Map<String, Object?>> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? interests,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<Map<String, Object?>> login({
    required String username,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? interests,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        Endpoints.register,
        data: AuthMapper.registerToJson(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          password: password,
          gender: gender,
          dateOfBirth: dateOfBirth,
          interests: interests,
        ),
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return data.cast<String, Object?>();
      }

      throw const UnknownException(message: 'Invalid register response.');
    } on DioException catch (error) {
      final dynamic payload = error.response?.data;
      if (payload is Map<String, dynamic>) {
        throw ErrorMapper.map(payload);
      }

      throw UnknownException(
        message: error.message ?? 'Unable to register.',
      );
    }
  }
}
