import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../domain/use_cases/change_password_use_case.dart';

enum ChangePasswordStatus { initial, loading, success, failure }

class ChangePasswordState {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.error,
  });

  final ChangePasswordStatus status;
  final Object? error;

  bool get isLoading => status == ChangePasswordStatus.loading;
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePasswordUseCase)
    : super(const ChangePasswordState());

  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (state.isLoading) return;

    emit(const ChangePasswordState(status: ChangePasswordStatus.loading));
    final Result<bool> result = await _changePasswordUseCase(
      ChangePasswordParams(oldPassword: oldPassword, newPassword: newPassword),
    );

    result.fold(
      (ResultFailure<bool> failure) => emit(
        ChangePasswordState(
          status: ChangePasswordStatus.failure,
          error: failure.cause ?? failure.message,
        ),
      ),
      (_) =>
          emit(const ChangePasswordState(status: ChangePasswordStatus.success)),
    );
  }
}
