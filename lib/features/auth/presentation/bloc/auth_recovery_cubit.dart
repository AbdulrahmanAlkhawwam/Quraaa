import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/architecture/result.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/forgot_password_use_case.dart';
import '../../domain/use_cases/reset_password_use_case.dart';
import '../../domain/use_cases/verify_otp_use_case.dart';

enum AuthRecoveryStatus { initial, loading, success, failure, navigate }

enum AuthRecoverySuccess { none, forgotPasswordSent, passwordReset, otpVerified }

@immutable
class AuthRecoveryState {
  const AuthRecoveryState({
    this.status = AuthRecoveryStatus.initial,
    this.success = AuthRecoverySuccess.none,
    this.error,
    this.nextRoute,
    this.routeExtra,
    this.navigationSerial = 0,
    this.resendCountdown = 0,
  });

  static const Object _unset = Object();

  final AuthRecoveryStatus status;
  final AuthRecoverySuccess success;
  final Object? error;
  final String? nextRoute;
  final Object? routeExtra;
  final int navigationSerial;
  final int resendCountdown;

  bool get isLoading => status == AuthRecoveryStatus.loading;
  bool get canResendOtp => resendCountdown <= 0;

  AuthRecoveryState copyWith({
    AuthRecoveryStatus? status,
    AuthRecoverySuccess? success,
    Object? error = _unset,
    Object? nextRoute = _unset,
    Object? routeExtra = _unset,
    int? navigationSerial,
    int? resendCountdown,
  }) {
    return AuthRecoveryState(
      status: status ?? this.status,
      success: success ?? this.success,
      error: identical(error, _unset) ? this.error : error,
      nextRoute: identical(nextRoute, _unset)
          ? this.nextRoute
          : nextRoute as String?,
      routeExtra: identical(routeExtra, _unset) ? this.routeExtra : routeExtra,
      navigationSerial: navigationSerial ?? this.navigationSerial,
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }
}

class AuthRecoveryCubit extends Cubit<AuthRecoveryState> {
  AuthRecoveryCubit({
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required AuthLocalDataSource authJourney,
  })  : _forgotPasswordUseCase = forgotPasswordUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _authJourney = authJourney,
        super(const AuthRecoveryState());

  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final AuthLocalDataSource _authJourney;
  Timer? _resendTimer;

  Future<void> requestPasswordReset({
    required String phoneNumber,
    required String phoneIsoCode,
  }) async {
    emit(
      state.copyWith(
        status: AuthRecoveryStatus.loading,
        success: AuthRecoverySuccess.none,
        error: null,
      ),
    );

    final Result<bool> result = await _forgotPasswordUseCase(
      ForgotPasswordParams(phoneNumber: phoneNumber),
    );

    await result.fold(
      (ResultFailure<bool> failure) async => _emitFailure(failure),
      (_) async {
        await _authJourney.saveLastPhoneNumber(phoneNumber, phoneIsoCode);
        _emitNavigation(
          RouteNames.resetPassword,
          success: AuthRecoverySuccess.forgotPasswordSent,
          routeExtra: phoneNumber,
        );
      },
    );
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    emit(
      state.copyWith(
        status: AuthRecoveryStatus.loading,
        success: AuthRecoverySuccess.none,
        error: null,
      ),
    );

    final Result<bool> result = await _resetPasswordUseCase(
      ResetPasswordParams(
        phoneNumber: phoneNumber,
        code: code,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (ResultFailure<bool> failure) => _emitFailure(failure),
      (_) => _emitNavigation(
        RouteNames.login,
        success: AuthRecoverySuccess.passwordReset,
      ),
    );
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        status: AuthRecoveryStatus.loading,
        success: AuthRecoverySuccess.none,
        error: null,
      ),
    );

    final Result<User> result = await _verifyOtpUseCase(
      VerifyOtpParams(phoneNumber: phoneNumber, code: code),
    );

    await result.fold(
      (ResultFailure<User> failure) async => _emitFailure(failure),
      (User user) async {
        await _authJourney.markAuthenticatedSession(
          accessToken: user.accessToken,
          refreshToken: user.refreshToken,
          accessTokenExpiration: user.accessTokenExpiration,
        );
        _emitNavigation(
          RouteNames.home,
          success: AuthRecoverySuccess.otpVerified,
        );
      },
    );
  }

  void startOtpResendCountdown({int seconds = 60}) {
    if (state.resendCountdown > 0) return;
    _resendTimer?.cancel();
    emit(state.copyWith(resendCountdown: seconds));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final int nextValue = state.resendCountdown - 1;
      if (nextValue <= 0) {
        timer.cancel();
        emit(state.copyWith(resendCountdown: 0));
        return;
      }
      emit(state.copyWith(resendCountdown: nextValue));
    });
  }

  void _emitFailure<T>(ResultFailure<T> failure) {
    emit(
      state.copyWith(
        status: AuthRecoveryStatus.failure,
        success: AuthRecoverySuccess.none,
        error: failure.cause ?? failure.message,
      ),
    );
  }

  void _emitNavigation(
    String route, {
    required AuthRecoverySuccess success,
    Object? routeExtra,
  }) {
    emit(
      state.copyWith(
        status: AuthRecoveryStatus.navigate,
        success: success,
        nextRoute: route,
        routeExtra: routeExtra,
        navigationSerial: state.navigationSerial + 1,
        error: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
