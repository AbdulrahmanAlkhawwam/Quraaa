import '../../../../core/architecture/base_repository.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/libraries_repository.dart';
import '../datasources/libraries_remote_data_source.dart';

class LibrariesRepositoryImpl extends BaseRepository<LibrariesPage>
    implements LibrariesRepository {
  const LibrariesRepositoryImpl(this._remoteDataSource);

  final LibrariesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<LibrariesPage>> getLibraries({
    required String searchTerm,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await _remoteDataSource.getLibraries(
        searchTerm: searchTerm,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return Success(
        LibrariesPage(
          items: response.items
              .map((model) => model.toEntity())
              .toList(growable: false),
          pageNumber: response.pageNumber,
          pageSize: response.pageSize,
          totalCount: response.totalCount,
          totalPages: response.totalPages,
          hasNextPage: response.hasNextPage,
          hasPreviousPage: response.hasPreviousPage,
        ),
      );
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure(failure.message, cause: failure);
    }
  }

  @override
  Future<LibrariesPage> getCached() {
    throw UnimplementedError();
  }

  @override
  Future<LibrariesPage> sync() {
    throw UnimplementedError();
  }
}
