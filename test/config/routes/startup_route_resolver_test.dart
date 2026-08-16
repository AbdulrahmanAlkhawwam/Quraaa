import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/config/routes/route_names.dart';
import 'package:quraaa/config/routes/route_resolver.dart';
import 'package:quraaa/core/connectivity/connection_status.dart';
import 'package:quraaa/core/connectivity/connectivity_service.dart';
import 'package:quraaa/core/di/injection_container.dart';
import 'package:quraaa/core/error_monitoring/user_context_provider.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quraaa/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:quraaa/features/onboarding/domain/repositories/onboarding_repository.dart';

void main() {
  group('resolveStartupRoute', () {
    late _MockOnboardingRepository onboardingRepository;
    late _MockAuthLocalDataSource authLocalDataSource;
    late _MockConnectivityService connectivityService;
    late _MockUserContextProvider userContextProvider;

    setUp(() async {
      await sl.reset();
      onboardingRepository = _MockOnboardingRepository();
      authLocalDataSource = _MockAuthLocalDataSource();
      connectivityService = _MockConnectivityService();
      userContextProvider = _MockUserContextProvider();

      sl.registerSingleton<OnboardingRepository>(onboardingRepository);
      sl.registerSingleton<AuthLocalDataSource>(authLocalDataSource);
      sl.registerSingleton<ConnectivityService>(connectivityService);
      sl.registerSingleton<UserContextProvider>(userContextProvider);

      when(() => onboardingRepository.loadState()).thenAnswer(
        (_) async => const OnboardingDraft(
          completed: false,
          selectedGender: null,
          selectedCategoryIds: null,
          birthYear: null,
          birthMonth: null,
          birthDay: null,
        ),
      );
    });

    tearDown(() => sl.reset());

    test('skips onboarding and starts a guest session when offline', () async {
      when(
        () => authLocalDataSource.getSessionMode(),
      ).thenAnswer((_) async => null);
      when(
        () => authLocalDataSource.getCurrentStage(),
      ).thenAnswer((_) async => AuthJourneyStage.onboarding);
      when(
        () => connectivityService.currentStatus(),
      ).thenAnswer((_) async => ConnectionStatus.disconnected);
      when(
        () => authLocalDataSource.markGuestSession(),
      ).thenAnswer((_) async {});
      when(() => userContextProvider.clearUser()).thenAnswer((_) async {});

      expect(await resolveStartupRoute(), RouteNames.home);
      verify(() => authLocalDataSource.markGuestSession()).called(1);
      verify(() => userContextProvider.clearUser()).called(1);
    });

    test('keeps normal onboarding routing when online', () async {
      when(
        () => authLocalDataSource.getSessionMode(),
      ).thenAnswer((_) async => null);
      when(
        () => authLocalDataSource.getCurrentStage(),
      ).thenAnswer((_) async => AuthJourneyStage.onboarding);
      when(
        () => connectivityService.currentStatus(),
      ).thenAnswer((_) async => ConnectionStatus.connected);

      expect(await resolveStartupRoute(), RouteNames.onboarding);
      verifyNever(() => authLocalDataSource.markGuestSession());
    });

    test('preserves an authenticated session while offline', () async {
      when(
        () => authLocalDataSource.getSessionMode(),
      ).thenAnswer((_) async => AuthSessionMode.authenticated);
      when(
        () => authLocalDataSource.getCurrentStage(),
      ).thenAnswer((_) async => AuthJourneyStage.home);

      expect(await resolveStartupRoute(), RouteNames.home);
      verifyNever(() => connectivityService.currentStatus());
      verifyNever(() => authLocalDataSource.markGuestSession());
    });
  });
}

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _MockUserContextProvider extends Mock implements UserContextProvider {}
