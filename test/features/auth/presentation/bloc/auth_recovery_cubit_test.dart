import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/config/routes/route_names.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quraaa/features/auth/domain/domain.dart';
import 'package:quraaa/features/auth/presentation/bloc/auth_recovery_cubit.dart';

void main() {
  test('requestPasswordReset saves phone and navigates to reset password',
      () async {
    final _FakeAuthRepository repository = _FakeAuthRepository();
    final _FakeAuthLocalDataSource authJourney = _FakeAuthLocalDataSource();
    final AuthRecoveryCubit cubit = _createCubit(repository, authJourney);
    addTearDown(cubit.close);

    await cubit.requestPasswordReset(
      phoneNumber: '+963999111222',
      phoneIsoCode: 'SY',
    );

    expect(cubit.state.status, AuthRecoveryStatus.navigate);
    expect(cubit.state.success, AuthRecoverySuccess.forgotPasswordSent);
    expect(cubit.state.nextRoute, RouteNames.resetPassword);
    expect(cubit.state.routeExtra, '+963999111222');
    expect(authJourney.lastPhoneNumber, '+963999111222');
    expect(authJourney.lastPhoneIsoCode, 'SY');
  });

  test('resetPassword emits failure when repository fails', () async {
    final _FakeAuthRepository repository = _FakeAuthRepository(
      resetPasswordResult: const ResultFailure<bool>('reset failed'),
    );
    final AuthRecoveryCubit cubit = _createCubit(
      repository,
      _FakeAuthLocalDataSource(),
    );
    addTearDown(cubit.close);

    await cubit.resetPassword(
      phoneNumber: '+963999111222',
      code: '123456',
      newPassword: 'pass123',
    );

    expect(cubit.state.status, AuthRecoveryStatus.failure);
    expect(cubit.state.error, 'reset failed');
  });

  test('verifyOtp marks authenticated session and navigates home', () async {
    final _FakeAuthRepository repository = _FakeAuthRepository();
    final _FakeAuthLocalDataSource authJourney = _FakeAuthLocalDataSource();
    final AuthRecoveryCubit cubit = _createCubit(repository, authJourney);
    addTearDown(cubit.close);

    await cubit.verifyOtp(phoneNumber: '+963999111222', code: '123456');

    expect(cubit.state.status, AuthRecoveryStatus.navigate);
    expect(cubit.state.success, AuthRecoverySuccess.otpVerified);
    expect(cubit.state.nextRoute, RouteNames.home);
    expect(authJourney.accessToken, 'access');
    expect(authJourney.refreshToken, 'refresh');
  });
}

AuthRecoveryCubit _createCubit(
  _FakeAuthRepository repository,
  _FakeAuthLocalDataSource authJourney,
) {
  return AuthRecoveryCubit(
    forgotPasswordUseCase: ForgotPasswordUseCase(repository),
    resetPasswordUseCase: ResetPasswordUseCase(repository),
    verifyOtpUseCase: VerifyOtpUseCase(repository),
    authJourney: authJourney,
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.resetPasswordResult = const Success<bool>(true)});

  final Result<bool> resetPasswordResult;

  @override
  Future<Result<bool>> forgotPassword({required String phoneNumber}) async {
    return const Success<bool>(true);
  }

  @override
  Future<Result<bool>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    return resetPasswordResult;
  }

  @override
  Future<Result<User>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    return const Success<User>(
      User(accessToken: 'access', refreshToken: 'refresh'),
    );
  }

  @override
  Future<Result<User>> login({
    required String phoneNumber,
    required String password,
  }) async {
    return const ResultFailure<User>('not used in recovery tests');
  }

  @override
  Future<Result<User>> refreshToken({required String refreshToken}) async {
    return const ResultFailure<User>('not used in recovery tests');
  }

  @override
  Future<Result<User>> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  }) async {
    return const ResultFailure<User>('not used in recovery tests');
  }
}

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  String? lastPhoneNumber;
  String? lastPhoneIsoCode;
  String? accessToken;
  String? refreshToken;
  AuthJourneyStage? currentStage;
  AuthJourneyStage? previousStage;

  @override
  Future<void> saveLastPhoneNumber(String phoneNumber, String isoCode) async {
    lastPhoneNumber = phoneNumber;
    lastPhoneIsoCode = isoCode;
  }

  @override
  Future<void> markAuthenticatedSession({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiration,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

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
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<Map<String, Object?>> getCachedUser() async => <String, Object?>{};

  @override
  Future<AuthJourneyStage?> getCurrentStage() async => currentStage;

  @override
  Future<String?> getLastPhoneIsoCode() async => lastPhoneIsoCode;

  @override
  Future<String?> getLastPhoneNumber() async => lastPhoneNumber;

  @override
  Future<AuthJourneyStage?> getPreviousStage() async => previousStage;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<AuthSessionMode?> getSessionMode() async => null;

  @override
  Future<DateTime?> getAccessTokenExpiration() async => null;

  @override
  Future<bool> isAuthSeen() async => false;

  @override
  Future<bool> isAuthenticatedSession() async => accessToken != null;

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
  Future<void> markGuestSession() async {}

  @override
  Future<void> markLocationPermissionSeen() async {}

  @override
  Future<void> markLoginSeen() async {}

  @override
  Future<void> markNotificationPermissionSeen() async {}

  @override
  Future<void> markRegisterSeen() async {}
}
