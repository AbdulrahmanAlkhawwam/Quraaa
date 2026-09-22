import '../../domain/repositories/auth_journey_repository.dart';
import '../data_sources/auth_local_data_source.dart';

class AuthJourneyRepositoryImpl implements AuthJourneyRepository {
  const AuthJourneyRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<void> markAuthSeen() => _local.markAuthSeen();

  @override
  Future<void> markLoginSeen() => _local.markLoginSeen();

  @override
  Future<void> markRegisterSeen() => _local.markRegisterSeen();

  @override
  Future<String?> getLastPhoneNumber() => _local.getLastPhoneNumber();

  @override
  Future<String?> getLastPhoneIsoCode() => _local.getLastPhoneIsoCode();

  @override
  Future<void> saveLastPhoneNumber(String phoneNumber, String isoCode) =>
      _local.saveLastPhoneNumber(phoneNumber, isoCode);

  @override
  Future<void> saveJourneyStage(
    AuthJourneyStage stage, {
    AuthJourneyStage? previousStage,
  }) => _local.saveJourneyStage(stage, previousStage: previousStage);

  @override
  Future<void> markGuestSession() => _local.markGuestSession();

  @override
  Future<bool> isNotificationPermissionSeen() =>
      _local.isNotificationPermissionSeen();

  @override
  Future<void> markNotificationPermissionSeen() =>
      _local.markNotificationPermissionSeen();

  @override
  Future<bool> isLocationPermissionSeen() => _local.isLocationPermissionSeen();

  @override
  Future<void> markLocationPermissionSeen() =>
      _local.markLocationPermissionSeen();
}
