import '../../../../core/architecture/use_case.dart';
import '../entities/local_directory_snapshot.dart';
import '../repositories/local_file_repository.dart';

class LoadLocalDirectoryParams {
  const LoadLocalDirectoryParams({this.path});

  final String? path;
}

class LoadLocalDirectoryUseCase
    extends UseCase<LocalDirectorySnapshot, LoadLocalDirectoryParams> {
  const LoadLocalDirectoryUseCase(this._repository);

  final LocalFileRepository _repository;

  @override
  Future<LocalDirectorySnapshot> call(LoadLocalDirectoryParams params) {
    return _repository.loadDirectory(path: params.path);
  }
}
