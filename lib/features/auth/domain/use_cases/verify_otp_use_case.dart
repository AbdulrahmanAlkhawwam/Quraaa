import '../../../../core/use_cases/use_case.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  const VerifyOtpParams({required this.phoneNumber, required this.code});

  final String phoneNumber;
  final String code;
}

class VerifyOtpUseCase extends UseCase<User, VerifyOtpParams> {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<User> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      phoneNumber: params.phoneNumber,
      code: params.code,
    );
  }
}
