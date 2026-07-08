import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  const VerifyOtpParams({required this.phoneNumber, required this.code});

  final String phoneNumber;
  final String code;
}

class VerifyOtpUseCase extends UseCase<Result<User>, VerifyOtpParams> {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      phoneNumber: params.phoneNumber,
      code: params.code,
    );
  }
}
