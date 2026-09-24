import '../../../../core/use_cases/use_case.dart';
import '../repositories/local_file_repository.dart';

class RequestLocalStorageAccessUseCase extends NoParamsUseCase<bool> {
  const RequestLocalStorageAccessUseCase(this._repository);

  final LocalFileRepository _repository;

  @override
  FutureEither<bool> call() {
    return _repository.requestStorageAccess();
  }
}
