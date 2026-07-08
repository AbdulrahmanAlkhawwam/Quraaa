import '../../../../core/architecture/base_repository.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/library_details_repository.dart';
import '../datasources/library_details_remote_data_source.dart';

class LibraryDetailsRepositoryImpl extends BaseRepository<LibraryBooksPage>
    implements LibraryDetailsRepository {
  const LibraryDetailsRepositoryImpl(this._remoteDataSource);

  final LibraryDetailsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<LibraryBooksPage>> getLibraryBooks({
    required String libraryId,
    required int pageNumber,
    required int pageSize,
    String? searchTerm,
    String? sortBy,
    bool? sortDescending,
  }) async {
    try {
      final response = await _remoteDataSource.getLibraryBooks(
        libraryId: libraryId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
        sortBy: sortBy,
        sortDescending: sortDescending,
      );

      return Success(
        LibraryBooksPage(
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
  Future<LibraryBooksPage> getCached() {
    throw UnimplementedError();
  }

  @override
  Future<LibraryBooksPage> sync() {
    throw UnimplementedError();
  }
}
