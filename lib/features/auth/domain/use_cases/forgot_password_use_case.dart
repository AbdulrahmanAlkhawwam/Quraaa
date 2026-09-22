import '../../../../core/use_cases/use_case.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordParams {
  const ForgotPasswordParams({required this.phoneNumber});

  final String phoneNumber;
}

class ForgotPasswordUseCase extends UseCase<bool, ForgotPasswordParams> {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<bool> call(ForgotPasswordParams params) {
    return _repository.forgotPassword(phoneNumber: params.phoneNumber);
  }
}
