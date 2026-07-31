$ErrorActionPreference = 'Stop'

$modelPath = 'lib\features\profile\data\models\profile_model.dart'
$model = @'
import '../../domain/entities/profile.dart';

/// Data model for the `/profile/me` response and local cache payload.
class ProfileModel extends Profile {
  const ProfileModel({
    super.userId,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.gender,
    super.role,
    super.dateOfBirth,
    super.profileImageUrl,
    super.interests,
    super.location,
    super.lastLoginDate,
    super.previousLoginDate,
    super.creationTime,
    super.lastModificationTime,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: _asInt(json['gender']),
      role: _asInt(json['role']),
      dateOfBirth: json['dateOfBirth'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      interests: _parseInterests(json['interests']),
      location: _parseLocation(json['location']),
      lastLoginDate: json['lastLoginDate'] as String?,
      previousLoginDate: json['previousLoginDate'] as String?,
      creationTime: json['creationTime'] as String?,
      lastModificationTime: json['lastModificationTime'] as String?,
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      userId: profile.userId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      phoneNumber: profile.phoneNumber,
      gender: profile.gender,
      role: profile.role,
      dateOfBirth: profile.dateOfBirth,
      profileImageUrl: profile.profileImageUrl,
      interests: profile.interests,
      location: profile.location,
      lastLoginDate: profile.lastLoginDate,
      previousLoginDate: profile.previousLoginDate,
      creationTime: profile.creationTime,
      lastModificationTime: profile.lastModificationTime,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'gender': gender,
    'role': role,
    'dateOfBirth': dateOfBirth,
    'profileImageUrl': profileImageUrl,
    'interests': interests
        .map(
          (ProfileInterest interest) => <String, dynamic>{
            'id': interest.id,
            'nameAr': interest.nameAr,
            'nameEn': interest.nameEn,
          },
        )
        .toList(growable: false),
    'location': location == null
        ? null
        : <String, dynamic>{
            'latitude': location!.latitude,
            'longitude': location!.longitude,
          },
    'lastLoginDate': lastLoginDate,
    'previousLoginDate': previousLoginDate,
    'creationTime': creationTime,
    'lastModificationTime': lastModificationTime,
  };

  static List<ProfileInterest> _parseInterests(Object? raw) {
    if (raw is! List<dynamic>) {
      return const <ProfileInterest>[];
    }
    return raw.map((dynamic item) {
      if (item is Map<String, dynamic>) {
        return ProfileInterest(
          id: item['id']?.toString() ?? '',
          nameAr: item['nameAr']?.toString() ?? '',
          nameEn: item['nameEn']?.toString() ?? '',
        );
      }
      return ProfileInterest(id: item.toString(), nameAr: '', nameEn: '');
    }).where((ProfileInterest item) => item.id.isNotEmpty).toList(growable: false);
  }

  static ProfileLocation? _parseLocation(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final double? latitude = _asDouble(raw['latitude']);
    final double? longitude = _asDouble(raw['longitude']);
    if (latitude == null || longitude == null) {
      return null;
    }
    return ProfileLocation(latitude: latitude, longitude: longitude);
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
'@
Set-Content -LiteralPath $modelPath -Value $model -NoNewline

$remotePath = 'lib\features\profile\data\datasources\profile_remote_data_source.dart'
$remote = @'
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
  Future<ProfileModel> getMyProfile() => _profileRequest(
    () => _httpHelper.get(ApiEndpoints.profileMe),
  );

  @override
  Future<ProfileModel> updateMyProfile(
    UpdateProfileRequestModel request,
  ) => _profileRequest(
    () => _httpHelper.put(
      ApiEndpoints.profileMe,
      data: request.toJson(),
    ),
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
  Future<void> deleteLocation() => _voidRequest(
    () => _httpHelper.delete(ApiEndpoints.profileLocation),
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
        ErrorResponseModel.fromJson(payload),
      );
    }

    return UnknownException(
      message: error.message ?? 'Unable to update profile.',
    );
  }
}
'@
Set-Content -LiteralPath $remotePath -Value $remote -NoNewline

$domainRepoPath = 'lib\features\profile\domain\repositories\profile_repository.dart'
$domainRepo = @'
import '../entities/profile.dart';
import '../entities/update_profile_input.dart';

abstract class ProfileRepository {
  Future<Profile> getMyProfile();
  Future<Profile?> getCachedProfile();
  Future<Profile> updateMyProfile(UpdateProfileInput input);
  Future<Profile> updateLocation(ProfileLocation location);
  Future<Profile?> deleteLocation();
}
'@
Set-Content -LiteralPath $domainRepoPath -Value $domainRepo -NoNewline

$repoPath = 'lib\features\profile\data\repositories\profile_repository_impl.dart'
$repo = @'
import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_input.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  @override
  Future<Profile> getMyProfile() async {
    final ProfileModel profile = await _remoteDataSource.getMyProfile();
    await _localDataSource.cacheProfile(profile);
    return profile;
  }

  @override
  Future<Profile?> getCachedProfile() => _localDataSource.getCachedProfile();

  @override
  Future<Profile> updateMyProfile(UpdateProfileInput input) async {
    final ProfileModel profile = await _remoteDataSource.updateMyProfile(
      UpdateProfileRequestModel(input),
    );
    await _localDataSource.cacheProfile(profile);
    return profile;
  }

  @override
  Future<Profile> updateLocation(ProfileLocation location) async {
    await _remoteDataSource.updateLocation(location);
    final Profile current = await _cachedOrRemote();
    final ProfileModel updated = ProfileModel.fromEntity(
      current.copyWith(location: location),
    );
    await _localDataSource.cacheProfile(updated);
    return updated;
  }

  @override
  Future<Profile?> deleteLocation() async {
    await _remoteDataSource.deleteLocation();
    final Profile? current = await _localDataSource.getCachedProfile();
    if (current == null) {
      return null;
    }
    final ProfileModel updated = ProfileModel.fromEntity(
      current.copyWith(clearLocation: true),
    );
    await _localDataSource.cacheProfile(updated);
    return updated;
  }

  Future<Profile> _cachedOrRemote() async {
    final Profile? cached = await _localDataSource.getCachedProfile();
    return cached ?? getMyProfile();
  }
}
'@
Set-Content -LiteralPath $repoPath -Value $repo -NoNewline

$httpPath = 'lib\core\network\http_helper.dart'
$http = Get-Content -Raw -LiteralPath $httpPath
$postNeedle = @'
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
'@
if (-not $http.Contains('Future<Response<dynamic>> put(')) {
  $methods = $postNeedle + @'

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<dynamic>(path, data: data, options: options);
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.delete<dynamic>(path, data: data, options: options);
  }
'@
  $http = $http.Replace($postNeedle, $methods)
  Set-Content -LiteralPath $httpPath -Value $http -NoNewline
}

$endpointPath = 'lib\core\constants\api_endpoints.dart'
$endpoints = Get-Content -Raw -LiteralPath $endpointPath
if (-not $endpoints.Contains('profileLocation')) {
  $endpoints = $endpoints.Replace("  static const String profileMe = '/profile/me';", "  static const String profileMe = '/profile/me';`r`n  static const String profileLocation = '/profile/location';")
  Set-Content -LiteralPath $endpointPath -Value $endpoints -NoNewline
}
