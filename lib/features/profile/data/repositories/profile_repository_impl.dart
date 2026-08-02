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
    final Profile? cachedProfile = await _localDataSource.getCachedProfile();
    final ProfileModel remoteProfile = await _remoteDataSource.getMyProfile();
    final ProfileModel profile = _mergeCachedLocationLabel(
      remoteProfile,
      cachedProfile,
    );
    await _localDataSource.cacheProfile(profile);
    return profile;
  }

  @override
  Future<Profile?> getCachedProfile() => _localDataSource.getCachedProfile();

  @override
  Future<Profile> updateMyProfile(UpdateProfileInput input) async {
    final Profile? cachedProfile = await _localDataSource.getCachedProfile();
    final ProfileModel remoteProfile = await _remoteDataSource.updateMyProfile(
      UpdateProfileRequestModel(input),
    );
    final ProfileModel profile = _mergeCachedLocationLabel(
      remoteProfile,
      cachedProfile,
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
    final bool sameLocation =
        remoteLocation != null &&
        cachedLocation != null &&
        (remoteLocation.latitude - cachedLocation.latitude).abs() < 0.000001 &&
        (remoteLocation.longitude - cachedLocation.longitude).abs() < 0.000001;
    if (!sameUser || !sameLocation || label.isEmpty) {
      return remoteProfile;
    }
    return ProfileModel.fromEntity(
      remoteProfile.copyWith(
        location: ProfileLocation(
          latitude: remoteLocation.latitude,
          longitude: remoteLocation.longitude,
          label: label,
        ),
      ),
    );
  }

  Future<Profile> _cachedOrRemote() async {
    final Profile? cached = await _localDataSource.getCachedProfile();
    return cached ?? getMyProfile();
  }
}
