import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({
    required this.phoneNumber,
    required this.password,
  });

  final String phoneNumber;
  final String password;
}

class LoginUseCase extends UseCase<Result<User>, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(LoginParams params) {
    return _repository.login(
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}
