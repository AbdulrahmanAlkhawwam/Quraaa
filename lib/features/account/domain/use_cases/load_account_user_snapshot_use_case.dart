import '../../../../core/architecture/use_case.dart';
import '../entities/account_user_snapshot.dart';
import '../repositories/account_repository.dart';

class LoadAccountUserSnapshotUseCase
    extends UseCase<AccountUserSnapshot, NoParams> {
  const LoadAccountUserSnapshotUseCase(this._repository);

  final AccountRepository _repository;

  @override
  Future<AccountUserSnapshot> call(NoParams params) {
    return _repository.loadUserSnapshot();
  }
}