import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams {
  const ResetPasswordParams({
    required this.phoneNumber,
    required this.code,
    required this.newPassword,
  });

  final String phoneNumber;
  final String code;
  final String newPassword;
}

class ResetPasswordUseCase extends UseCase<Result<bool>, ResetPasswordParams> {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      phoneNumber: params.phoneNumber,
      code: params.code,
      newPassword: params.newPassword,
    );
  }
}
