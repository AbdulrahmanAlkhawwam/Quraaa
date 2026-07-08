import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordParams {
  const ForgotPasswordParams({required this.phoneNumber});

  final String phoneNumber;
}

class ForgotPasswordUseCase
    extends UseCase<Result<bool>, ForgotPasswordParams> {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call(ForgotPasswordParams params) {
    return _repository.forgotPassword(phoneNumber: params.phoneNumber);
  }
}
