import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quraaa/features/auth/data/models/user_model.dart';
import 'package:quraaa/features/auth/domain/entities/user.dart';
import 'package:quraaa/features/auth/domain/use_cases/login_use_case.dart';
import 'package:quraaa/features/auth/domain/use_cases/register_use_case.dart';
import 'package:quraaa/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockAuthLocalDataSource authJourney;
  late MockUserLocalDataSource userCache;
  late MockUserContextProvider userContext;

  setUpAll(() {
    registerFallbackValue(const UserModel());
    registerFallbackValue(const LoginParams(phoneNumber: '', password: ''));
    registerFallbackValue(const RegisterParams());
  });

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    authJourney = MockAuthLocalDataSource();
    userCache = MockUserLocalDataSource();
    userContext = MockUserContextProvider();
  });

  AuthBloc createBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      authJourney: authJourney,
      userCache: userCache,
      userContext: userContext,
    );
  }

  const accessToken = 'access_token';
  const refreshToken = 'refresh_token';
  const phoneNumber = '+1234567890';
  const password = 'secret';

  User createUser({String? firstName, String? lastName}) {
    return User(
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void stubAuthenticatedSideEffects() {
    when(
      () => authJourney.markAuthenticatedSession(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => userCache.saveUser(any())).thenAnswer((_) async {});
    when(
      () => userContext.setUser(
        id: any(named: 'id'),
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        subscriptionStatus: any(named: 'subscriptionStatus'),
      ),
    ).thenAnswer((_) async {});
  }

  group('AuthBloc', () {
    test('initial state is AuthState with init status', () {
      expect(createBloc().state, const AuthState());
    });

    group('AuthLoginRequested', () {
      test('emits loading then success on success', () async {
        final user = createUser();
        when(
          () => loginUseCase(any()),
        ).thenAnswer((_) async => Success(user));
        stubAuthenticatedSideEffects();

        final bloc = createBloc();
        bloc.add(
          AuthLoginRequested(
            phoneNumber: phoneNumber,
            password: password,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.success),
          ]),
        );

        verify(
          () => authJourney.markAuthenticatedSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        ).called(1);
        verify(() => userCache.saveUser(any(that: isA<UserModel>()))).called(1);
        verify(
          () => userContext.setUser(
            id: phoneNumber,
            name: phoneNumber,
            phone: phoneNumber,
            subscriptionStatus: 'active',
          ),
        ).called(1);
      });

      test('emits loading then error on failure', () async {
        final failure = ResultFailure<User>('login failed');
        when(
          () => loginUseCase(any()),
        ).thenAnswer((_) async => failure);

        final bloc = createBloc();
        bloc.add(
          AuthLoginRequested(
            phoneNumber: phoneNumber,
            password: password,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(<AuthState>[
            const AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.error, error: failure),
          ]),
        );
      });
    });

    group('AuthRegisterRequested', () {
      test('emits loading then success on success', () async {
        final user = createUser();
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => Success(user));
        stubAuthenticatedSideEffects();

        final bloc = createBloc();
        bloc.add(
          AuthRegisterRequested(
            phoneNumber: phoneNumber,
            password: password,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.success),
          ]),
        );

        verify(
          () => authJourney.markAuthenticatedSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        ).called(1);
        verify(() => userCache.saveUser(any(that: isA<UserModel>()))).called(1);
        verify(
          () => userContext.setUser(
            id: phoneNumber,
            name: '',
            phone: phoneNumber,
            subscriptionStatus: 'active',
          ),
        ).called(1);
      });

      test('joins first and last name when provided', () async {
        final user = createUser(firstName: 'First', lastName: 'Last');
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => Success(user));
        stubAuthenticatedSideEffects();

        final bloc = createBloc();
        bloc.add(
          AuthRegisterRequested(
            firstName: 'First',
            lastName: 'Last',
            phoneNumber: phoneNumber,
            password: password,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(const <AuthState>[
            AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.success),
          ]),
        );

        verify(
          () => userContext.setUser(
            id: phoneNumber,
            name: 'First Last',
            phone: phoneNumber,
            subscriptionStatus: 'active',
          ),
        ).called(1);
      });

      test('emits loading then error on failure', () async {
        final failure = ResultFailure<User>('register failed');
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => failure);

        final bloc = createBloc();
        bloc.add(
          AuthRegisterRequested(
            phoneNumber: phoneNumber,
            password: password,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder(<AuthState>[
            const AuthState(status: AuthStatus.loading),
            AuthState(status: AuthStatus.error, error: failure),
          ]),
        );
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
