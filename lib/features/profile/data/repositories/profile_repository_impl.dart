import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_input.dart';
import '../../domain/repositories/profile_repository.dart';
import '../data_sources/profile_local_data_source.dart';
import '../data_sources/profile_remote_data_source.dart';
import '../models/profile_model.dart';
import '../models/update_profile_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  @override
  FutureEither<Profile> getMyProfile() {
    return _guard(() async {
      final Profile? cachedProfile = await _localDataSource.getCachedProfile();
      final ProfileModel remoteProfile = await _remoteDataSource.getMyProfile();
      final ProfileModel profile = _mergeCachedLocationLabel(
        remoteProfile,
        cachedProfile,
      );
      await _localDataSource.cacheProfile(profile);
      return profile;
    });
  }

  @override
  FutureEither<Profile?> getCachedProfile() {
    return _guard(_localDataSource.getCachedProfile);
  }

  @override
  FutureEither<Profile> updateMyProfile(UpdateProfileInput input) {
    return _guard(() => _updateMyProfile(input));
  }

  @override
  FutureEither<List<ProfileLocation>> getLocations() => _guard(_fetchLocations);

  @override
  FutureEither<List<ProfileLocation>> updateLocation(ProfileLocation location) {
    return _guard(() async {
      await _remoteDataSource.updateLocation(location);
      return _fetchLocations();
    });
  }

  @override
  FutureEither<List<ProfileLocation>> deleteLocation(ProfileLocation location) {
    return _guard(() async {
      await _remoteDataSource.deleteLocation(location);
      return _fetchLocations();
    });
  }

  @override
  FutureEither<List<ProfileLocation>> setDefaultLocation(
    ProfileLocation location,
  ) {
    return _guard(() async {
      final String? id = location.id;
      if (id != null && id.isNotEmpty) {
        await _remoteDataSource.setDefaultLocation(id);
      }
      return _fetchLocations();
    });
  }

  /// One try/catch for every call: anything thrown below the domain boundary
  /// becomes a typed [Failure] via [ErrorMapper].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  Future<Profile> _updateMyProfile(UpdateProfileInput input) async {
    final Profile? cachedProfile = await _localDataSource.getCachedProfile();
    final int gender = ProfileGenderValue.isSupported(input.gender)
        ? input.gender
        : ProfileGenderValue.normalize(cachedProfile?.gender);
    final UpdateProfileInput effectiveInput = UpdateProfileInput(
      firstName: input.firstName,
      lastName: input.lastName,
      gender: gender,
      dateOfBirth: input.dateOfBirth,
      profileImageUrl: input.profileImageUrl,
      interestIds: input.interestIds,
    );
    final ProfileModel remoteProfile = await _remoteDataSource.updateMyProfile(
      UpdateProfileRequestModel(effectiveInput),
    );
    final ProfileModel profile = _mergeCachedLocationLabel(
      remoteProfile,
      cachedProfile,
    );
    await _localDataSource.cacheProfile(profile);
    return profile;
  }

  Future<List<ProfileLocation>> _fetchLocations() async {
    final List<ProfileLocation> locations =
        await _remoteDataSource.getLocations();
    await _cacheDefaultLocation(locations);
    return locations;
  }

  Future<void> _cacheDefaultLocation(
    List<ProfileLocation> locations,
  ) async {
    final Profile? current = await _localDataSource.getCachedProfile();
    if (current == null) {
      return;
    }
    ProfileLocation? defaultLocation;
    for (final ProfileLocation location in locations) {
      if (location.isDefault) {
        defaultLocation = location;
        break;
      }
    }
    defaultLocation ??= locations.isEmpty ? null : locations.first;
    final ProfileModel updated = ProfileModel.fromEntity(
      current.copyWith(
        location: defaultLocation,
        clearLocation: defaultLocation == null,
      ),
    );
    await _localDataSource.cacheProfile(updated);
  }

  ProfileModel _mergeCachedLocationLabel(
    ProfileModel remoteProfile,
    Profile? cachedProfile,
  ) {
    final ProfileLocation? remoteLocation = remoteProfile.location;
    final ProfileLocation? cachedLocation = cachedProfile?.location;
    final String label = cachedLocation?.label?.trim() ?? '';
    final String remoteUserId = remoteProfile.userId?.trim() ?? '';
    final String cachedUserId = cachedProfile?.userId?.trim() ?? '';
    final bool sameUser =
        remoteUserId.isNotEmpty && remoteUserId == cachedUserId;
    final bool sameLocation = remoteLocation != null &&
        cachedLocation != null &&
        (remoteLocation.latitude - cachedLocation.latitude).abs() < 0.000001 &&
        (remoteLocation.longitude - cachedLocation.longitude).abs() < 0.000001;
    if (!sameUser || !sameLocation || label.isEmpty) {
      return remoteProfile;
    }
    return ProfileModel.fromEntity(
      remoteProfile.copyWith(
        location: ProfileLocation(
          id: remoteLocation.id,
          latitude: remoteLocation.latitude,
          longitude: remoteLocation.longitude,
          name: label,
          address: remoteLocation.address,
          isDefault: remoteLocation.isDefault,
          creationTime: remoteLocation.creationTime,
          lastModificationTime: remoteLocation.lastModificationTime,
        ),
      ),
    );
  }
}
