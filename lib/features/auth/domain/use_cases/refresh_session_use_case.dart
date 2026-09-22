import '../../../../core/use_cases/use_case.dart';
import '../repositories/auth_repository.dart';

/// Rotates the stored session; `Right` carries the new access token.
class RefreshSessionUseCase extends NoParamsUseCase<String> {
  const RefreshSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureEither<String> call() => _repository.refreshSession();
}
