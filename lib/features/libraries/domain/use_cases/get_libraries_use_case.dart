import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/libraries_repository.dart';

class GetLibrariesParams {
  const GetLibrariesParams({
    required this.searchTerm,
    required this.pageNumber,
    required this.pageSize,
  });

  final String searchTerm;
  final int pageNumber;
  final int pageSize;
}

class GetLibrariesUseCase
    extends UseCase<Result<LibrariesPage>, GetLibrariesParams> {
  const GetLibrariesUseCase(this._repository);

  final LibrariesRepository _repository;

  @override
  Future<Result<LibrariesPage>> call(GetLibrariesParams params) {
    return _repository.getLibraries(
      searchTerm: params.searchTerm,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}
