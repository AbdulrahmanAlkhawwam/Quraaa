import '../../../../core/use_cases/use_case.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends NoParamsUseCase<bool> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<bool> call() => _repository.logout();
}
