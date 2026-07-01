import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getMyProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<ProfileModel> getMyProfile() async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.profileMe,
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return ProfileModel.fromJson(data);
      }

      throw const UnknownException(message: 'Invalid profile response.');
    } on DioException catch (error) {
      final dynamic payload = error.response?.data;
      if (payload is Map<String, dynamic>) {
        throw ErrorMapper.map(payload);
      }

      throw UnknownException(
        message: error.message ?? 'Unable to load profile.',
      );
    }
  }
}
