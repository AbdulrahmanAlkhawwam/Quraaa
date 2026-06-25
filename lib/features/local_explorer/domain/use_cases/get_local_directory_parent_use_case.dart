import '../../../../core/architecture/use_case.dart';
import '../repositories/local_file_repository.dart';
import '../value_objects/result.dart';

class GetLocalDirectoryParentParams {
  const GetLocalDirectoryParentParams({required this.path});

  final String path;
}

class GetLocalDirectoryParentUseCase
    extends UseCase<Result<String?>, GetLocalDirectoryParentParams> {
  const GetLocalDirectoryParentUseCase(this._repository);

  final LocalFileRepository _repository;

  @override
  Future<Result<String?>> call(GetLocalDirectoryParentParams params) async {
    return _repository.parentOf(params.path);
  }
}
