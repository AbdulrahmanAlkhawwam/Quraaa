import '../../../../core/architecture/use_case.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

class LoginUseCase extends UseCase<AuthUser, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(LoginParams params) {
    return _repository.login(
      username: params.username,
      password: params.password,
    );
  }
}
