import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/features/account/data/repositories/account_repository_impl.dart';
import 'package:quraaa/features/account/data/user_data_local_data_source.dart';
import 'package:quraaa/features/account/domain/entities/account_user_snapshot.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quraaa/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:quraaa/features/profile/data/models/profile_model.dart';

class _MockUserDataLocalDataSource extends Mock
    implements UserDataLocalDataSource {}

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class _MockProfileLocalDataSource extends Mock
    implements ProfileLocalDataSource {}

void main() {
  late _MockUserDataLocalDataSource localDataSource;
  late _MockAuthLocalDataSource authLocalDataSource;
  late _MockProfileLocalDataSource profileLocalDataSource;
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
    authLocalDataSource = _MockAuthLocalDataSource();
    profileLocalDataSource = _MockProfileLocalDataSource();
    repository = AccountRepositoryImpl(
      localDataSource,
      authLocalDataSource,
      profileLocalDataSource,
    );
    when(() => localDataSource.load()).thenAnswer((_) async => localSnapshot);
  });

  test('uses the authenticated user name cached after login', () async {
    when(
      () => authLocalDataSource.isAuthenticatedSession(),
    ).thenAnswer((_) async => true);
    when(() => profileLocalDataSource.getCachedProfile()).thenAnswer(
      (_) async => const ProfileModel(firstName: 'Maya', lastName: 'Haddad'),
    );

    final AccountUserSnapshot snapshot = await repository.loadUserSnapshot();

    expect(snapshot.fullName, 'Maya Haddad');
    expect(snapshot.firstName, 'Maya');
  });

  test(
    'uses the app name for a guest and ignores stale cached users',
    () async {
      when(
        () => authLocalDataSource.isAuthenticatedSession(),
      ).thenAnswer((_) async => false);

      final AccountUserSnapshot snapshot = await repository.loadUserSnapshot();

      expect(snapshot.fullName, 'Quraaa');
      verifyNever(() => profileLocalDataSource.getCachedProfile());
    },
  );
}
