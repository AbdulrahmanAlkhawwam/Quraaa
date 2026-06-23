import '../../../../core/architecture/use_case.dart';
import '../repositories/local_file_repository.dart';
import '../value_objects/result.dart';

class RequestLocalStorageAccessUseCase extends UseCase<Result<bool>, NoParams> {
  const RequestLocalStorageAccessUseCase(this._repository);

  final LocalFileRepository _repository;

  @override
  Future<Result<bool>> call(NoParams params) {
    return _repository.requestStorageAccess();
  }
}
