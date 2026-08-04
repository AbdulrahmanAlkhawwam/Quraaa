import '../entities/profile.dart';
import '../entities/update_profile_input.dart';

abstract class ProfileRepository {
  Future<Profile> getMyProfile();
  Future<Profile?> getCachedProfile();
  Future<Profile> updateMyProfile(UpdateProfileInput input);
  Future<Profile> updateLocation(ProfileLocation location);
  Future<Profile?> deleteLocation();
}
