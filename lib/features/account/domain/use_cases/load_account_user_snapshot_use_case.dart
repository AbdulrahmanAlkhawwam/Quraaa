import '../../../../core/use_cases/use_case.dart';
import '../entities/account_user_snapshot.dart';
import '../repositories/account_repository.dart';

class LoadAccountUserSnapshotUseCase
    extends NoParamsUseCase<AccountUserSnapshot> {
  const LoadAccountUserSnapshotUseCase(this._repository);

  final AccountRepository _repository;

  @override
  FutureEither<AccountUserSnapshot> call() => _repository.loadUserSnapshot();
}
