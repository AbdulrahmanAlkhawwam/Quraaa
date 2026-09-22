import '../../../../core/use_cases/use_case.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase extends UseCase<bool, String> {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<bool> call(String phoneNumber) {
    return _repository.sendOtp(phoneNumber: phoneNumber);
  }
}
