import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_location_model.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getMyProfile();
  Future<ProfileModel> updateMyProfile(UpdateProfileRequestModel request);
  Future<List<ProfileLocationModel>> getLocations();
  Future<void> updateLocation(ProfileLocation location);
  Future<void> deleteLocation(ProfileLocation location);
  Future<void> setDefaultLocation(String locationId);
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
  Future<List<ProfileLocationModel>> getLocations() async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.profileLocation,
      );
      return ProfileLocationModel.listFromJson(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw UnknownException(message: error.message);
    }
  }

  @override
  Future<void> updateLocation(ProfileLocation location) async {
    final ProfileLocationModel request = ProfileLocationModel(
      id: location.id,
      name: location.name,
      address: location.address,
      latitude: location.latitude,
      longitude: location.longitude,
      isDefault: location.isDefault,
      creationTime: location.creationTime,
      lastModificationTime: location.lastModificationTime,
    );
    await _voidRequest(
      () => location.id == null
          ? _httpHelper.post(
              ApiEndpoints.profileLocation,
              data: request.toRequestJson(),
            )
          : _httpHelper.put(
              ApiEndpoints.profileLocationById(location.id!),
              data: request.toRequestJson(),
            ),
    );
  }

  @override
  Future<void> deleteLocation(ProfileLocation location) => _voidRequest(
        () => _httpHelper.delete(
          location.id == null
              ? ApiEndpoints.profileLocation
              : ApiEndpoints.profileLocationById(location.id!),
        ),
      );

  @override
  Future<void> setDefaultLocation(String locationId) => _voidRequest(
        () => _httpHelper.put(
          ApiEndpoints.profileLocationDefault(locationId),
        ),
      );

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
        ErrorResponseModel.fromJson(
          payload,
          statusCode: error.response?.statusCode,
        ),
      );
    }

    return UnknownException(
      message: error.message ?? 'Unable to update profile.',
    );
  }
}
