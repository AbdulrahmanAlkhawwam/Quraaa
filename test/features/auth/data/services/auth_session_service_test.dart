import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/features/auth/data/models/user_model.dart';
import 'package:quraaa/features/auth/data/services/auth_session_service.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  late MockAuthLocalDataSource authLocalDataSource;
  late MockUserLocalDataSource userLocalDataSource;
  late MockUserContextProvider userContextProvider;
  late AuthSessionService service;

  setUpAll(() => registerFallbackValue(const UserModel()));

  setUp(() {
    authLocalDataSource = MockAuthLocalDataSource();
    userLocalDataSource = MockUserLocalDataSource();
    userContextProvider = MockUserContextProvider();
    service = AuthSessionService(
      authLocalDataSource: authLocalDataSource,
      userLocalDataSource: userLocalDataSource,
      userContextProvider: userContextProvider,
    );
  });

  test(
    'writes the authenticated marker after user cache and context',
    () async {
      when(() => userLocalDataSource.saveUser(any())).thenAnswer((_) async {});
      when(
        () => userContextProvider.setUser(
          id: any(named: 'id'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          subscriptionStatus: any(named: 'subscriptionStatus'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => authLocalDataSource.markAuthenticatedSession(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      await service.completeAuthenticatedSession(
        const UserModel(accessToken: 'access', refreshToken: 'refresh'),
        fallbackId: '+963999111222',
        fallbackPhone: '+963999111222',
      );

      verifyInOrder(<void Function()>[
        () => userLocalDataSource.saveUser(
          const UserModel(
            phoneNumber: '+963999111222',
            accessToken: 'access',
            refreshToken: 'refresh',
          ),
        ),
        () => userContextProvider.setUser(
          id: '+963999111222',
          name: '+963999111222',
          phone: '+963999111222',
          subscriptionStatus: 'active',
        ),
        () => authLocalDataSource.markAuthenticatedSession(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      ]);
    },
  );

  test('persists rotated tokens after a successful refresh', () async {
    final DateTime expiration = DateTime.utc(2026, 8, 7, 12);
    when(
      () => userLocalDataSource.updateTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
        accessTokenExpiration: expiration,
      ),
    ).thenAnswer((_) async {});
    when(
      () => authLocalDataSource.markAuthenticatedSession(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
        accessTokenExpiration: expiration,
      ),
    ).thenAnswer((_) async {});

    final String? accessToken = await service.refreshAuthenticatedSession(
      UserModel(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
        accessTokenExpiration: expiration,
      ),
      previousRefreshToken: 'old-refresh',
    );

    expect(accessToken, 'new-access');
    verifyInOrder(<void Function()>[
      () => userLocalDataSource.updateTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
        accessTokenExpiration: expiration,
      ),
      () => authLocalDataSource.markAuthenticatedSession(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
        accessTokenExpiration: expiration,
      ),
    ]);
  });

  test('rolls back local state when session finalization fails', () async {
    when(
      () => userLocalDataSource.saveUser(any()),
    ).thenThrow(StateError('cache failed'));
    when(() => userLocalDataSource.clearUser()).thenAnswer((_) async {});
    when(() => userContextProvider.clearUser()).thenAnswer((_) async {});
    when(() => authLocalDataSource.clearSession()).thenAnswer((_) async {});

    await expectLater(
      service.completeAuthenticatedSession(
        const UserModel(accessToken: 'access', refreshToken: 'refresh'),
        fallbackId: 'user',
      ),
      throwsStateError,
    );

    verify(() => userLocalDataSource.clearUser()).called(1);
    verify(() => userContextProvider.clearUser()).called(1);
    verify(() => authLocalDataSource.clearSession()).called(1);
    verifyNever(
      () => authLocalDataSource.markAuthenticatedSession(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    );
  });
}
