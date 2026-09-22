import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/constants/app_routes.dart';
import 'package:quraaa/features/auth/domain/entities/auth_journey.dart';
import 'package:quraaa/features/auth/domain/entities/user.dart';
import 'package:quraaa/features/auth/domain/use_cases/login_use_case.dart';
import 'package:quraaa/features/auth/domain/use_cases/register_use_case.dart';
import 'package:quraaa/features/auth/presentation/logic/auth_bloc.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockAuthJourneyRepository authJourney;
  late MockUserContextProvider userContext;

  setUpAll(() {
    registerFallbackValue(const LoginParams(phoneNumber: '', password: ''));
    registerFallbackValue(const RegisterParams());
  });

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    authJourney = MockAuthJourneyRepository();
    userContext = MockUserContextProvider();
  });

  AuthBloc createBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      authJourney: authJourney,
      userContext: userContext,
    );
  }

  const phoneNumber = '+1234567890';
  const password = 'secret';
  const user = User(phoneNumber: phoneNumber);

  group('AuthBloc', () {
    test('initial state is AuthState with init status', () {
      expect(createBloc().state, const AuthState());
    });

    group('AuthLoginRequested', () {
      // Session persistence happens inside AuthRepository.login and is
      // covered by auth_repository_impl_test; the bloc only reacts.
      test('emits loading then success on success', () async {
        when(
          () => loginUseCase(any()),
        ).thenAnswer((_) async => const Right(user));

        final bloc = createBloc();
        bloc.add(
          AuthLoginRequested(phoneNumber: phoneNumber, password: password),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.success),
          ]),
        );
      });

      test('emits loading then the typed failure on failure', () async {
        const failure = LoginFailure(message: 'login failed');
        when(
          () => loginUseCase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final bloc = createBloc();
        bloc.add(
          AuthLoginRequested(phoneNumber: phoneNumber, password: password),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.error, error: failure),
          ]),
        );
      });
    });

    group('AuthRegisterRequested', () {
      test('emits loading then success on success', () async {
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => const Right(user));
        when(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.otpVerification,
            previousStage: AuthJourneyStage.register,
          ),
        ).thenAnswer((_) async {});

        final bloc = createBloc();
        bloc.add(
          AuthRegisterRequested(phoneNumber: phoneNumber, password: password),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.success),
          ]),
        );

        verify(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.otpVerification,
            previousStage: AuthJourneyStage.register,
          ),
        ).called(1);
      });

      test('emits loading then the typed failure on failure', () async {
        const failure = UnknownFailure(message: 'register failed');
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final bloc = createBloc();
        bloc.add(
          AuthRegisterRequested(phoneNumber: phoneNumber, password: password),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.error, error: failure),
          ]),
        );
      });

      test('navigates pending unverified registration to OTP', () async {
        when(() => registerUseCase(any())).thenAnswer(
          (_) async => const Left(
            OtpVerificationRequiredFailure(
              message: 'Account is pending OTP verification.',
            ),
          ),
        );
        when(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.otpVerification,
            previousStage: AuthJourneyStage.register,
          ),
        ).thenAnswer((_) async {});

        final AuthBloc bloc = createBloc();
        bloc.add(
          const AuthRegisterRequested(
            phoneNumber: phoneNumber,
            password: password,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.success),
            AuthState(
              status: AuthStatus.success,
              nextRoute: AppRoutes.otpVerification,
              routeExtra: phoneNumber,
              navigationSerial: 1,
            ),
          ]),
        );

        verify(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.otpVerification,
            previousStage: AuthJourneyStage.register,
          ),
        ).called(1);
      });
    });

    group('AuthStarted', () {
      test('marks auth seen and resets state', () async {
        when(() => authJourney.markAuthSeen()).thenAnswer((_) async {});

        final bloc = createBloc();
        bloc.add(AuthStarted());

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[AuthState()]),
        );

        verify(() => authJourney.markAuthSeen()).called(1);
      });
    });

    group('AuthOnboardingRequested', () {
      test('emits navigation loading then navigate to onboarding', () async {
        when(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.onboarding,
            previousStage: AuthJourneyStage.auth,
          ),
        ).thenAnswer((_) async {});

        final bloc = createBloc();
        bloc.add(AuthOnboardingRequested());

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(
              status: AuthStatus.navigationLoading,
              destination: AuthNavigationDestination.onboarding,
            ),
            AuthState(status: AuthStatus.navigateToOnboarding),
          ]),
        );

        verify(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.onboarding,
            previousStage: AuthJourneyStage.auth,
          ),
        ).called(1);
      });
    });

    group('AuthLoginRequestedFromAuth', () {
      test('emits navigation loading then navigate to login', () async {
        when(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.login,
            previousStage: AuthJourneyStage.auth,
          ),
        ).thenAnswer((_) async {});

        final bloc = createBloc();
        bloc.add(AuthLoginRequestedFromAuth());

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(
              status: AuthStatus.navigationLoading,
              destination: AuthNavigationDestination.login,
            ),
            AuthState(status: AuthStatus.navigateToLogin),
          ]),
        );

        verify(
          () => authJourney.saveJourneyStage(
            AuthJourneyStage.login,
            previousStage: AuthJourneyStage.auth,
          ),
        ).called(1);
      });
    });
  });
}
