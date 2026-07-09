import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quraaa/features/auth/presentation/bloc/auth_journey_cubit.dart';

void main() {
  test('moveFromInterestsToRegister saves current and previous stages',
      () async {
    final _FakeAuthLocalDataSource authJourney = _FakeAuthLocalDataSource();
    final AuthJourneyCubit cubit = AuthJourneyCubit(authJourney: authJourney);
    addTearDown(cubit.close);

    await cubit.moveFromInterestsToRegister();

    expect(authJourney.currentStage, AuthJourneyStage.register);
    expect(authJourney.previousStage, AuthJourneyStage.onboardingInterests);
  });

  test('enterOnboardingAge saves onboarding age as current stage', () async {
    final _FakeAuthLocalDataSource authJourney = _FakeAuthLocalDataSource();
    final AuthJourneyCubit cubit = AuthJourneyCubit(authJourney: authJourney);
    addTearDown(cubit.close);

    await cubit.enterOnboardingAge();

    expect(authJourney.currentStage, AuthJourneyStage.onboardingAge);
  });
}

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  AuthJourneyStage? currentStage;
  AuthJourneyStage? previousStage;

  @override
  Future<void> saveJourneyStage(
    AuthJourneyStage stage, {
    AuthJourneyStage? previousStage,
  }) async {
    currentStage = stage;
    this.previousStage = previousStage;
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<DateTime?> getAccessTokenExpiration() async => null;

  @override
  Future<Map<String, Object?>> getCachedUser() async => <String, Object?>{};

  @override
  Future<AuthJourneyStage?> getCurrentStage() async => currentStage;

  @override
  Future<String?> getLastPhoneIsoCode() async => null;

  @override
  Future<String?> getLastPhoneNumber() async => null;

  @override
  Future<AuthJourneyStage?> getPreviousStage() async => previousStage;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<AuthSessionMode?> getSessionMode() async => null;

  @override
  Future<bool> isAuthSeen() async => false;

  @override
  Future<bool> isAuthenticatedSession() async => false;

  @override
  Future<bool> isGuestSession() async => false;

  @override
  Future<bool> isLocationPermissionSeen() async => false;

  @override
  Future<bool> isLoginSeen() async => false;

  @override
  Future<bool> isNotificationPermissionSeen() async => false;

  @override
  Future<bool> isRegisterSeen() async => false;

  @override
  Future<void> markAuthSeen() async {}

  @override
  Future<void> markAuthenticatedSession({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiration,
  }) async {}

  @override
  Future<void> markGuestSession() async {}

  @override
  Future<void> markLocationPermissionSeen() async {}

  @override
  Future<void> markLoginSeen() async {}

  @override
  Future<void> markNotificationPermissionSeen() async {}

  @override
  Future<void> markRegisterSeen() async {}

  @override
  Future<void> saveLastPhoneNumber(String phoneNumber, String isoCode) async {}
}
