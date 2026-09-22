import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/connectivity/connection_status.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/auth/domain/repositories/auth_session_repository.dart';
import 'package:quraaa/features/auth/domain/use_cases/refresh_session_use_case.dart';
import 'package:quraaa/features/profile/domain/entities/profile.dart';
import 'package:quraaa/features/profile/domain/use_cases/get_cached_profile_use_case.dart';
import 'package:quraaa/features/profile/domain/use_cases/get_my_profile_use_case.dart';
import 'package:quraaa/features/profile/presentation/logic/profile_bloc.dart';
import 'package:quraaa/features/profile/presentation/logic/profile_event.dart';
import 'package:quraaa/features/profile/presentation/logic/profile_state.dart';

import '../../../../mocks/mock_classes.dart';

class _MockGetMyProfile extends Mock implements GetMyProfileUseCase {}

class _MockGetCachedProfile extends Mock implements GetCachedProfileUseCase {}

class _MockRefreshSession extends Mock implements RefreshSessionUseCase {}

class _MockAuthSession extends Mock implements AuthSessionRepository {}

void main() {
  late _MockGetMyProfile getMyProfile;
  late _MockGetCachedProfile getCachedProfile;
  late _MockRefreshSession refreshSession;
  late _MockAuthSession authSession;
  late MockConnectivityService connectivity;

  const Profile profile = Profile(userId: 'user-1', firstName: 'Nour');
  const Failure expired = UnauthorizedFailure(message: 'expired');

  setUp(() {
    getMyProfile = _MockGetMyProfile();
    getCachedProfile = _MockGetCachedProfile();
    refreshSession = _MockRefreshSession();
    authSession = _MockAuthSession();
    connectivity = MockConnectivityService();
    when(() => authSession.hasStoredTokens()).thenAnswer((_) async => true);
    when(
      () => authSession.isAuthenticatedSession(),
    ).thenAnswer((_) async => true);
    when(() => authSession.signOutLocally()).thenAnswer((_) async {});
    when(
      () => connectivity.currentStatus(),
    ).thenAnswer((_) async => ConnectionStatus.connected);
  });

  ProfileBloc build() => ProfileBloc(
    getMyProfile: getMyProfile,
    getCachedProfile: getCachedProfile,
    refreshSession: refreshSession,
    authSession: authSession,
    connectivityService: connectivity,
  );

  Future<ProfileState> load(ProfileBloc bloc) async {
    bloc.add(const ProfileLoadRequested());
    return bloc.stream.firstWhere((ProfileState s) => !s.loading);
  }

  test('stays idle without stored tokens', () async {
    when(() => authSession.hasStoredTokens()).thenAnswer((_) async => false);
    final ProfileBloc bloc = build();
    addTearDown(bloc.close);

    final ProfileState state = await load(bloc);

    expect(state.profile, isNull);
    expect(state.error, isNull);
    verifyNever(() => getMyProfile());
  });

  test('uses the cached profile while offline', () async {
    when(
      () => connectivity.currentStatus(),
    ).thenAnswer((_) async => ConnectionStatus.disconnected);
    when(() => getCachedProfile()).thenAnswer((_) async => const Right(profile));
    final ProfileBloc bloc = build();
    addTearDown(bloc.close);

    final ProfileState state = await load(bloc);

    expect(state.profile, profile);
    verifyNever(() => getMyProfile());
  });

  test('a non-auth failure is shown without refreshing', () async {
    const Failure server = ServerFailure(message: 'boom');
    when(() => getMyProfile()).thenAnswer((_) async => const Left(server));
    final ProfileBloc bloc = build();
    addTearDown(bloc.close);

    final ProfileState state = await load(bloc);

    expect(state.error, server);
    expect(state.requiresLogin, isFalse);
    verifyNever(() => refreshSession());
  });

  group('on 401', () {
    test('refreshes once, retries, and shows the profile', () async {
      final List<Either<Failure, Profile>> answers = <Either<Failure, Profile>>[
        const Left(expired),
        const Right(profile),
      ];
      when(() => getMyProfile()).thenAnswer((_) async => answers.removeAt(0));
      when(
        () => refreshSession(),
      ).thenAnswer((_) async => const Right('new-access'));
      final ProfileBloc bloc = build();
      addTearDown(bloc.close);

      final ProfileState state = await load(bloc);

      expect(state.profile, profile);
      expect(state.requiresLogin, isFalse);
      verify(() => refreshSession()).called(1);
      verifyNever(() => authSession.signOutLocally());
    });

    test('signs out and asks for login when refresh fails', () async {
      when(() => getMyProfile()).thenAnswer((_) async => const Left(expired));
      when(() => refreshSession()).thenAnswer(
        (_) async => const Left(TokenExpiredFailure(message: 'refresh dead')),
      );
      final ProfileBloc bloc = build();
      addTearDown(bloc.close);

      final ProfileState state = await load(bloc);

      expect(state.requiresLogin, isTrue);
      expect((state.error! as Failure).message, 'refresh dead');
      verify(() => authSession.signOutLocally()).called(1);
    });

    test('does not refresh again when the interceptor already signed out',
        () async {
      when(() => getMyProfile()).thenAnswer((_) async => const Left(expired));
      when(
        () => authSession.isAuthenticatedSession(),
      ).thenAnswer((_) async => false);
      final ProfileBloc bloc = build();
      addTearDown(bloc.close);

      final ProfileState state = await load(bloc);

      expect(state.requiresLogin, isTrue);
      verifyNever(() => refreshSession());
    });
  });
}
