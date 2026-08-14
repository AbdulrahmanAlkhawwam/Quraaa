import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite_book.dart';
import '../../domain/repositories/favorite_books_repository.dart';
import '../datasources/favorite_books_remote_data_source.dart';
import '../models/favorite_book_model.dart';

class FavoriteBooksRepositoryImpl implements FavoriteBooksRepository {
  FavoriteBooksRepositoryImpl(this._remoteDataSource);

  final FavoriteBooksRemoteDataSource _remoteDataSource;
  final Set<String> _knownBookIds = <String>{};

  @override
  Future<Result<FavoriteBooksPage>> getFavoriteBooks({
    required int pageNumber,
    required int pageSize,
    String searchTerm = '',
  }) async {
    try {
      final FavoriteBooksPageModel model = await _remoteDataSource
          .getFavoriteBooks(
            pageNumber: pageNumber,
            pageSize: pageSize,
            searchTerm: searchTerm,
          );
      final FavoriteBooksPage page = _toPage(model);
      _knownBookIds.addAll(page.items.map((item) => item.bookId));
      return Success<FavoriteBooksPage>(page);
    } catch (error) {
      return _failure<FavoriteBooksPage>(error);
    }
  }

  @override
  Future<Result<FavoriteBook>> addFavorite(String bookId) async {
    try {
      final FavoriteBook favorite = (await _remoteDataSource.addFavorite(
        bookId,
      )).toEntity();
      _knownBookIds.add(bookId);
      return Success<FavoriteBook>(favorite);
    } catch (error) {
      return _failure<FavoriteBook>(error);
    }
  }

  @override
  Future<Result<bool>> removeFavorite(String bookId) async {
    try {
      await _remoteDataSource.removeFavorite(bookId);
      _knownBookIds.remove(bookId);
      return const Success<bool>(true);
    } catch (error) {
      return _failure<bool>(error);
    }
  }

  @override
  Future<Result<bool>> isFavorite(String bookId) async {
    if (_knownBookIds.contains(bookId)) return const Success<bool>(true);
    int pageNumber = 1;
    try {
      while (true) {
        final FavoriteBooksPageModel model = await _remoteDataSource
            .getFavoriteBooks(
              pageNumber: pageNumber,
              pageSize: 100,
              searchTerm: '',
            );
        final Iterable<String> ids = model.items.map((item) => item.bookId);
        _knownBookIds.addAll(ids);
        if (_knownBookIds.contains(bookId)) return const Success<bool>(true);
        if (!model.hasNextPage || model.items.isEmpty) {
          return const Success<bool>(false);
        }
        pageNumber++;
      }
    } catch (error) {
      return _failure<bool>(error);
    }
  }

  FavoriteBooksPage _toPage(FavoriteBooksPageModel model) => FavoriteBooksPage(
    items: model.items.map((item) => item.toEntity()).toList(growable: false),
    pageNumber: model.pageNumber,
    pageSize: model.pageSize,
    totalCount: model.totalCount,
    totalPages: model.totalPages,
    hasNextPage: model.hasNextPage,
    hasPreviousPage: model.hasPreviousPage,
  );

  ResultFailure<T> _failure<T>(Object error) {
    final Failure failure = ErrorMapper.map(error);
    return ResultFailure<T>(failure.message, cause: failure);
  }
}
