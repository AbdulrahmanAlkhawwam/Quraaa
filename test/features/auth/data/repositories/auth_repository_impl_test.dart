import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/auth/data/models/user_model.dart';
import 'package:quraaa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quraaa/features/auth/domain/entities/user.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockAuthSessionService session;
  late AuthRepositoryImpl repository;

  const phone = '+963999111222';
  const signInJson = <String, Object?>{
    'id': 'user-1',
    'firstName': 'Nour',
    'phoneNumber': phone,
    'accessToken': 'access-1',
    'refreshToken': 'refresh-1',
  };

  setUpAll(() => registerFallbackValue(const UserModel()));

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    session = MockAuthSessionService();
    repository = AuthRepositoryImpl(remote, local, session);
  });

  void stubSessionCompletes() {
    when(
      () => session.completeAuthenticatedSession(
        any(),
        fallbackId: any(named: 'fallbackId'),
        fallbackName: any(named: 'fallbackName'),
        fallbackPhone: any(named: 'fallbackPhone'),
      ),
    ).thenAnswer((_) async {});
  }

  group('login', () {
    test('persists the session, then returns the token-free entity', () async {
      when(
        () => remote.login(phoneNumber: phone, password: 'pw'),
      ).thenAnswer((_) async => signInJson);
      stubSessionCompletes();

      final Either<Failure, User> result = await repository.login(
        phoneNumber: phone,
        password: 'pw',
      );

      final User user = result.getOrElse((_) => fail('expected Right'));
      expect(user, isNot(isA<UserModel>()));
      expect(user.id, 'user-1');
      final UserModel persisted =
          verify(
                () => session.completeAuthenticatedSession(
                  captureAny(),
                  fallbackId: phone,
                  fallbackPhone: phone,
                ),
              ).captured.single
              as UserModel;
      expect(persisted.accessToken, 'access-1');
      expect(persisted.refreshToken, 'refresh-1');
    });

    test('maps a remote exception to a typed failure', () async {
      when(
        () => remote.login(phoneNumber: phone, password: 'bad'),
      ).thenThrow(const UnauthorizedException(message: 'wrong password'));

      final Either<Failure, User> result = await repository.login(
        phoneNumber: phone,
        password: 'bad',
      );

      final Failure failure = result.getLeft().toNullable()!;
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'wrong password');
      verifyNever(
        () => session.completeAuthenticatedSession(
          any(),
          fallbackId: any(named: 'fallbackId'),
          fallbackPhone: any(named: 'fallbackPhone'),
        ),
      );
    });

    test('returns a failure instead of throwing when saving fails', () async {
      when(
        () => remote.login(phoneNumber: phone, password: 'pw'),
      ).thenAnswer((_) async => signInJson);
      when(
        () => session.completeAuthenticatedSession(
          any(),
          fallbackId: any(named: 'fallbackId'),
          fallbackPhone: any(named: 'fallbackPhone'),
        ),
      ).thenThrow(const CacheWriteException());

      final Either<Failure, User> result = await repository.login(
        phoneNumber: phone,
        password: 'pw',
      );

      expect(result.getLeft().toNullable(), isA<CacheWriteFailure>());
    });
  });

  test('verifyOtp persists the session like login', () async {
    when(
      () => remote.verifyOtp(phoneNumber: phone, code: '123456'),
    ).thenAnswer((_) async => signInJson);
    stubSessionCompletes();

    final Either<Failure, User> result = await repository.verifyOtp(
      phoneNumber: phone,
      code: '123456',
    );

    expect(result.isRight(), isTrue);
    verify(
      () => session.completeAuthenticatedSession(
        any(),
        fallbackId: phone,
        fallbackPhone: phone,
      ),
    ).called(1);
  });

  test('register returns the entity without starting a session', () async {
    when(
      () => remote.register(phoneNumber: phone, password: 'pw'),
    ).thenAnswer((_) async => signInJson);

    final Either<Failure, User> result = await repository.register(
      phoneNumber: phone,
      password: 'pw',
    );

    expect(result.getOrElse((_) => fail('expected Right')).id, 'user-1');
    verifyNever(
      () => session.completeAuthenticatedSession(
        any(),
        fallbackId: any(named: 'fallbackId'),
        fallbackPhone: any(named: 'fallbackPhone'),
      ),
    );
  });

  group('refreshSession', () {
    test('fails fast without a network call when no token is stored', () async {
      when(() => local.getRefreshToken()).thenAnswer((_) async => null);

      final Either<Failure, String> result = await repository.refreshSession();

      expect(result.getLeft().toNullable(), isA<TokenExpiredFailure>());
      verifyNever(
        () => remote.refreshToken(refreshToken: any(named: 'refreshToken')),
      );
    });

    test('rotates tokens and returns the new access token', () async {
      when(() => local.getRefreshToken()).thenAnswer((_) async => 'refresh-0');
      when(
        () => remote.refreshToken(refreshToken: 'refresh-0'),
      ).thenAnswer((_) async => signInJson);
      when(
        () => session.refreshAuthenticatedSession(
          any(),
          previousRefreshToken: 'refresh-0',
        ),
      ).thenAnswer((_) async => 'access-1');

      final Either<Failure, String> result = await repository.refreshSession();

      expect(result, const Right<Failure, String>('access-1'));
    });

    test('fails when the response carries no access token', () async {
      when(() => local.getRefreshToken()).thenAnswer((_) async => 'refresh-0');
      when(
        () => remote.refreshToken(refreshToken: 'refresh-0'),
      ).thenAnswer((_) async => <String, Object?>{});
      when(
        () => session.refreshAuthenticatedSession(
          any(),
          previousRefreshToken: 'refresh-0',
        ),
      ).thenAnswer((_) async => null);

      final Either<Failure, String> result = await repository.refreshSession();

      expect(result.getLeft().toNullable(), isA<TokenExpiredFailure>());
    });
  });

  test('logout sends the stored refresh token', () async {
    when(() => local.getRefreshToken()).thenAnswer((_) async => 'refresh-0');
    when(
      () => remote.logout(refreshToken: 'refresh-0'),
    ).thenAnswer((_) async {});

    final Either<Failure, bool> result = await repository.logout();

    expect(result, const Right<Failure, bool>(true));
    verify(() => remote.logout(refreshToken: 'refresh-0')).called(1);
  });
}
