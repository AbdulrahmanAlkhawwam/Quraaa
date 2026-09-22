import '../../../../core/use_cases/use_case.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordParams {
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;
}

class ChangePasswordUseCase extends UseCase<bool, ChangePasswordParams> {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<bool> call(ChangePasswordParams params) {
    return _repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}
