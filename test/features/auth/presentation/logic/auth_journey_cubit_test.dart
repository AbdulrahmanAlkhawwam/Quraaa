import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/auth/domain/entities/auth_journey.dart';
import 'package:quraaa/features/auth/domain/repositories/auth_journey_repository.dart';
import 'package:quraaa/features/auth/presentation/logic/auth_journey_cubit.dart';

void main() {
  test('moveFromInterestsToAge saves current and previous stages', () async {
    final _FakeAuthJourneyRepository authJourney = _FakeAuthJourneyRepository();
    final AuthJourneyCubit cubit = AuthJourneyCubit(authJourney: authJourney);
    addTearDown(cubit.close);

    await cubit.moveFromInterestsToAge();

    expect(authJourney.currentStage, AuthJourneyStage.onboardingAge);
    expect(authJourney.previousStage, AuthJourneyStage.onboardingInterests);
  });

  test('enterOnboardingAge saves onboarding age as current stage', () async {
    final _FakeAuthJourneyRepository authJourney = _FakeAuthJourneyRepository();
    final AuthJourneyCubit cubit = AuthJourneyCubit(authJourney: authJourney);
    addTearDown(cubit.close);

    await cubit.enterOnboardingAge();

    expect(authJourney.currentStage, AuthJourneyStage.onboardingAge);
  });
}

class _FakeAuthJourneyRepository implements AuthJourneyRepository {
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
  Future<String?> getLastPhoneIsoCode() async => null;

  @override
  Future<String?> getLastPhoneNumber() async => null;

  @override
  Future<bool> isLocationPermissionSeen() async => false;

  @override
  Future<bool> isNotificationPermissionSeen() async => false;

  @override
  Future<void> markAuthSeen() async {}

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
