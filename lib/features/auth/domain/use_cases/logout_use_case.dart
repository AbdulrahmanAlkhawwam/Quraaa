import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<Result<bool>, NoParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call(NoParams params) => _repository.logout();
}
