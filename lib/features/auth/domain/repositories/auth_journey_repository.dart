import '../entities/auth_journey.dart';

/// Device-local state of the sign-in journey: which screens were seen, the
/// last phone number typed, and the guest/authenticated marker.
///
/// These are best-effort UI conveniences backed by local storage, so they
/// return plain values instead of `Either`; callers treat a failure as
/// "not saved" and carry on.
abstract class AuthJourneyRepository {
  Future<void> markAuthSeen();

  Future<void> markLoginSeen();

  Future<void> markRegisterSeen();

  Future<String?> getLastPhoneNumber();

  Future<String?> getLastPhoneIsoCode();

  Future<void> saveLastPhoneNumber(String phoneNumber, String isoCode);

  Future<void> saveJourneyStage(
    AuthJourneyStage stage, {
    AuthJourneyStage? previousStage,
  });

  Future<void> markGuestSession();

  Future<bool> isNotificationPermissionSeen();

  Future<void> markNotificationPermissionSeen();

  Future<bool> isLocationPermissionSeen();

  Future<void> markLocationPermissionSeen();
}
