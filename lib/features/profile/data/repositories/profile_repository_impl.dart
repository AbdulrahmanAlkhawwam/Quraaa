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
