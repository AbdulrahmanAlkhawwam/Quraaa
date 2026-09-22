import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/account/data/repositories/account_repository_impl.dart';
import 'package:quraaa/features/account/data/data_sources/user_data_local_data_source.dart';
import 'package:quraaa/features/account/domain/entities/account_user_snapshot.dart';
import 'package:quraaa/features/auth/domain/repositories/auth_session_repository.dart';
import 'package:quraaa/features/profile/domain/entities/profile.dart';
import 'package:quraaa/features/profile/domain/repositories/profile_repository.dart';

class _MockUserDataLocalDataSource extends Mock
    implements UserDataLocalDataSource {}

class _MockAuthSession extends Mock implements AuthSessionRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockUserDataLocalDataSource localDataSource;
  late _MockAuthSession authSession;
  late _MockProfileRepository profileRepository;
  late AccountRepositoryImpl repository;

  const UserDataSnapshot localSnapshot = UserDataSnapshot(
    fullName: 'Legacy Name',
    birthDate: '',
    country: '',
    phone: '',
    theme: 'system',
    language: 'en',
    bookmarks: <String>[],
    budgetBalance: '',
    libraryItems: <String>[],
    operations: <String>[],
  );

  setUp(() {
    localDataSource = _MockUserDataLocalDataSource();
    authSession = _MockAuthSession();
    profileRepository = _MockProfileRepository();
    repository = AccountRepositoryImpl(
      localDataSource,
      authSession,
      profileRepository,
    );
    when(() => localDataSource.load()).thenAnswer((_) async => localSnapshot);
  });

  AccountUserSnapshot snapshotOf(Either<Failure, AccountUserSnapshot> r) =>
      r.getOrElse((_) => fail('expected Right'));

  test('uses the authenticated user name cached after login', () async {
    when(
      () => authSession.isAuthenticatedSession(),
    ).thenAnswer((_) async => true);
    when(() => profileRepository.getCachedProfile()).thenAnswer(
      (_) async =>
          const Right(Profile(firstName: 'Maya', lastName: 'Haddad')),
    );

    final AccountUserSnapshot snapshot = snapshotOf(
      await repository.loadUserSnapshot(),
    );

    expect(snapshot.fullName, 'Maya Haddad');
    expect(snapshot.firstName, 'Maya');
  });

  test(
    'uses the app name for a guest and ignores stale cached users',
    () async {
      when(
        () => authSession.isAuthenticatedSession(),
      ).thenAnswer((_) async => false);

      final AccountUserSnapshot snapshot = snapshotOf(
        await repository.loadUserSnapshot(),
      );

      expect(snapshot.fullName, 'Quraaa');
      verifyNever(() => profileRepository.getCachedProfile());
    },
  );

  test('falls back to the app name when the cached profile fails', () async {
    when(
      () => authSession.isAuthenticatedSession(),
    ).thenAnswer((_) async => true);
    when(
      () => profileRepository.getCachedProfile(),
    ).thenAnswer((_) async => const Left(CacheReadFailure()));

    final AccountUserSnapshot snapshot = snapshotOf(
      await repository.loadUserSnapshot(),
    );

    expect(snapshot.fullName, 'Quraaa');
  });

  test('returns a failure instead of throwing when local storage fails',
      () async {
    when(() => localDataSource.load()).thenThrow(const CacheReadException());

    final Either<Failure, AccountUserSnapshot> result = await repository
        .loadUserSnapshot();

    expect(result.getLeft().toNullable(), isA<CacheReadFailure>());
  });
}
