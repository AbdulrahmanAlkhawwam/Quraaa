import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase extends UseCase<Result<bool>, String> {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call(String phoneNumber) {
    return _repository.sendOtp(phoneNumber: phoneNumber);
  }
}
