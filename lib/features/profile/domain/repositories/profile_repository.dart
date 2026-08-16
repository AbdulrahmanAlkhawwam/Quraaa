import '../entities/profile.dart';
import '../entities/update_profile_input.dart';

abstract class ProfileRepository {
  Future<Profile> getMyProfile();
  Future<Profile?> getCachedProfile();
  Future<Profile> updateMyProfile(UpdateProfileInput input);
  Future<List<ProfileLocation>> getLocations();
  Future<List<ProfileLocation>> updateLocation(ProfileLocation location);
  Future<List<ProfileLocation>> deleteLocation(ProfileLocation location);
  Future<List<ProfileLocation>> setDefaultLocation(ProfileLocation location);
}
