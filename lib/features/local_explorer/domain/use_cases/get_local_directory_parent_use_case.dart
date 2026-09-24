import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repositories/local_file_repository.dart';

class GetLocalDirectoryParentParams {
  const GetLocalDirectoryParentParams({required this.path});

  final String path;
}

class GetLocalDirectoryParentUseCase
    extends SyncUseCase<String?, GetLocalDirectoryParentParams> {
  const GetLocalDirectoryParentUseCase(this._repository);

  final LocalFileRepository _repository;

  @override
  Either<Failure, String?> call(GetLocalDirectoryParentParams params) {
    return _repository.parentOf(params.path);
  }
}
