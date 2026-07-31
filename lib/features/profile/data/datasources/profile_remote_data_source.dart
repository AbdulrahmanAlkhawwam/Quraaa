import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getMyProfile();
  Future<ProfileModel> updateMyProfile(UpdateProfileRequestModel request);
  Future<void> updateLocation(ProfileLocation location);
  Future<void> deleteLocation();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<ProfileModel> getMyProfile() =>
      _profileRequest(() => _httpHelper.get(ApiEndpoints.profileMe));

  @override
  Future<ProfileModel> updateMyProfile(UpdateProfileRequestModel request) =>
      _profileRequest(
        () => _httpHelper.put(ApiEndpoints.profileMe, data: request.toJson()),
      );

  @override
  Future<void> updateLocation(ProfileLocation location) async {
    await _voidRequest(
      () => _httpHelper.post(
        ApiEndpoints.profileLocation,
        data: <String, dynamic>{
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      ),
    );
  }

  @override
  Future<void> deleteLocation() =>
      _voidRequest(() => _httpHelper.delete(ApiEndpoints.profileLocation));

  Future<ProfileModel> _profileRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final Response<dynamic> response = await request();
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        return ProfileModel.fromJson(data);
      }
      throw const UnknownException(message: 'Invalid profile response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> _voidRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      await request();
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final Object? underlying = error.error;
    if (underlying is AppException) {
      return underlying;
    }

    final dynamic payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(payload),
      );
    }

    return UnknownException(
      message: error.message ?? 'Unable to update profile.',
    );
  }
}
