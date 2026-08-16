import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/authors_repository.dart';
import '../datasources/authors_remote_data_source.dart';

class AuthorsRepositoryImpl implements AuthorsRepository {
  const AuthorsRepositoryImpl(this._remote);

  final AuthorsRemoteDataSource _remote;

  @override
  Future<Result<AuthorEntity>> getAuthor(String authorId) =>
      _result(() => _remote.getAuthor(authorId));

  @override
  Future<Result<AuthorBooksPage>> getAuthorBooks(
    String authorId, {
    int pageNumber = 1,
    int pageSize = 20,
  }) =>
      _result(
        () => _remote.getAuthorBooks(
          authorId,
          pageNumber: pageNumber,
          pageSize: pageSize,
        ),
      );

  @override
  Future<Result<AuthorSearchPage>> searchAuthors(
    String searchTerm, {
    int pageNumber = 1,
    int pageSize = 10,
  }) =>
      _result(
        () => _remote.searchAuthors(
          searchTerm,
          pageNumber: pageNumber,
          pageSize: pageSize,
        ),
      );

  Future<Result<T>> _result<T>(Future<T> Function() request) async {
    try {
      return Success<T>(await request());
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<T>(failure.message, cause: failure);
    }
  }
}
