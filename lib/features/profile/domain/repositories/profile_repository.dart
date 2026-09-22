import '../../../../core/use_cases/use_case.dart';
import '../entities/profile.dart';
import '../entities/update_profile_input.dart';

abstract class ProfileRepository {
  /// Fetches the profile from the backend and refreshes the local cache.
  FutureEither<Profile> getMyProfile();

  /// The last profile cached on this device, or `null` when none is stored.
  FutureEither<Profile?> getCachedProfile();

  FutureEither<Profile> updateMyProfile(UpdateProfileInput input);

  FutureEither<List<ProfileLocation>> getLocations();

  /// Each mutation returns the refreshed list from the backend.
  FutureEither<List<ProfileLocation>> updateLocation(ProfileLocation location);

  FutureEither<List<ProfileLocation>> deleteLocation(ProfileLocation location);

  FutureEither<List<ProfileLocation>> setDefaultLocation(
    ProfileLocation location,
  );
}
