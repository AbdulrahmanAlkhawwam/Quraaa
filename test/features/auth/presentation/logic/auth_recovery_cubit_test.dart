import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:quraaa/core/constants/app_routes.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/use_cases/use_case.dart';
import 'package:quraaa/features/auth/domain/domain.dart';
import 'package:quraaa/features/auth/presentation/logic/auth_recovery_cubit.dart';

void main() {
  test(
    'requestPasswordReset saves phone and navigates to reset password',
    () async {
      final _FakeAuthRepository repository = _FakeAuthRepository();
      final _FakeAuthJourneyRepository authJourney =
          _FakeAuthJourneyRepository();
      final AuthRecoveryCubit cubit = _createCubit(repository, authJourney);
      addTearDown(cubit.close);

      await cubit.requestPasswordReset(
        phoneNumber: '+963999111222',
        phoneIsoCode: 'SY',
      );

      expect(cubit.state.status, AuthRecoveryStatus.navigate);
      expect(cubit.state.success, AuthRecoverySuccess.forgotPasswordSent);
      expect(cubit.state.nextRoute, AppRoutes.resetPassword);
      expect(cubit.state.routeExtra, '+963999111222');
      expect(authJourney.lastPhoneNumber, '+963999111222');
      expect(authJourney.lastPhoneIsoCode, 'SY');
      expect(authJourney.currentStage, AuthJourneyStage.resetPassword);
    },
  );

  test('resetPassword emits the typed failure when repository fails', () async {
    const Failure failure = UnknownFailure(message: 'reset failed');
    final _FakeAuthRepository repository = _FakeAuthRepository(
      resetPasswordResult: const Left(failure),
    );
    final AuthRecoveryCubit cubit = _createCubit(
      repository,
      _FakeAuthJourneyRepository(),
    );
    addTearDown(cubit.close);

    await cubit.resetPassword(
      phoneNumber: '+963999111222',
      code: '123456',
      newPassword: 'pass123',
    );

    expect(cubit.state.status, AuthRecoveryStatus.failure);
    expect(cubit.state.error, failure);
  });

  test('verifyOtp navigates home once the repository signs in', () async {
    final _FakeAuthRepository repository = _FakeAuthRepository();
    final AuthRecoveryCubit cubit = _createCubit(
      repository,
      _FakeAuthJourneyRepository(),
    );
    addTearDown(cubit.close);

    await cubit.verifyOtp(phoneNumber: '+963999111222', code: '123456');

    expect(cubit.state.status, AuthRecoveryStatus.navigate);
    expect(cubit.state.success, AuthRecoverySuccess.otpVerified);
    expect(cubit.state.nextRoute, AppRoutes.home);
    expect(repository.verifiedPhoneNumber, '+963999111222');
  });

  test('verifyOtp surfaces the failure and stays put on error', () async {
    const Failure failure = UnauthorizedFailure(message: 'bad code');
    final _FakeAuthRepository repository = _FakeAuthRepository(
      verifyOtpResult: const Left(failure),
    );
    final AuthRecoveryCubit cubit = _createCubit(
      repository,
      _FakeAuthJourneyRepository(),
    );
    addTearDown(cubit.close);

    await cubit.verifyOtp(phoneNumber: '+963999111222', code: '000000');

    expect(cubit.state.status, AuthRecoveryStatus.failure);
    expect(cubit.state.error, failure);
    expect(cubit.state.nextRoute, isNull);
  });
}

AuthRecoveryCubit _createCubit(
  _FakeAuthRepository repository,
  _FakeAuthJourneyRepository authJourney,
) {
  return AuthRecoveryCubit(
    forgotPasswordUseCase: ForgotPasswordUseCase(repository),
    resetPasswordUseCase: ResetPasswordUseCase(repository),
    verifyOtpUseCase: VerifyOtpUseCase(repository),
    sendOtpUseCase: SendOtpUseCase(repository),
    authJourney: authJourney,
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.resetPasswordResult = const Right(true),
    this.verifyOtpResult = const Right(User(phoneNumber: '+963999111222')),
  });

  final Either<Failure, bool> resetPasswordResult;
  final Either<Failure, User> verifyOtpResult;
  String? verifiedPhoneNumber;

  static const Failure _unused = UnknownFailure(
    message: 'not used in recovery tests',
  );

  @override
  FutureEither<bool> sendOtp({required String phoneNumber}) async =>
      const Right(true);

  @override
  FutureEither<bool> logout() async => const Right(true);

  @override
  FutureEither<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async => const Right(true);

  @override
  FutureEither<bool> forgotPassword({required String phoneNumber}) async =>
      const Right(true);

  @override
  FutureEither<bool> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async => resetPasswordResult;

  @override
  FutureEither<User> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    verifiedPhoneNumber = phoneNumber;
    return verifyOtpResult;
  }

  @override
  FutureEither<User> login({
    required String phoneNumber,
    required String password,
  }) async => const Left(_unused);

  @override
  FutureEither<String> refreshSession() async => const Left(_unused);

  @override
  FutureEither<User> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  }) async => const Left(_unused);
}

class _FakeAuthJourneyRepository implements AuthJourneyRepository {
  String? lastPhoneNumber;
  String? lastPhoneIsoCode;
  AuthJourneyStage? currentStage;
  AuthJourneyStage? previousStage;

  @override
  Future<void> saveLastPhoneNumber(String phoneNumber, String isoCode) async {
    lastPhoneNumber = phoneNumber;
    lastPhoneIsoCode = isoCode;
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
  Future<String?> getLastPhoneIsoCode() async => lastPhoneIsoCode;

  @override
  Future<String?> getLastPhoneNumber() async => lastPhoneNumber;

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
}
