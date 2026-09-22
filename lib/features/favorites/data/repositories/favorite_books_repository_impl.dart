import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/favorite_book.dart';
import '../../domain/repositories/favorite_books_repository.dart';
import '../data_sources/favorite_books_remote_data_source.dart';
import '../models/favorite_book_model.dart';

class FavoriteBooksRepositoryImpl implements FavoriteBooksRepository {
  FavoriteBooksRepositoryImpl(this._remoteDataSource);

  final FavoriteBooksRemoteDataSource _remoteDataSource;
  final Set<String> _knownBookIds = <String>{};

  @override
  FutureEither<FavoriteBooksPage> getFavoriteBooks({
    required int pageNumber,
    required int pageSize,
    String searchTerm = '',
  }) {
    return _guard(() async {
      final FavoriteBooksPageModel model = await _remoteDataSource
          .getFavoriteBooks(
            pageNumber: pageNumber,
            pageSize: pageSize,
            searchTerm: searchTerm,
          );
      final FavoriteBooksPage page = _toPage(model);
      _knownBookIds.addAll(page.items.map((item) => item.bookId));
      return page;
    });
  }

  @override
  FutureEither<FavoriteBook> addFavorite(String bookId) {
    return _guard(() async {
      final FavoriteBook favorite = (await _remoteDataSource.addFavorite(
        bookId,
      )).toEntity();
      _knownBookIds.add(bookId);
      return favorite;
    });
  }

  @override
  FutureEither<bool> removeFavorite(String bookId) {
    return _guard(() async {
      await _remoteDataSource.removeFavorite(bookId);
      _knownBookIds.remove(bookId);
      return true;
    });
  }

  /// Answers from the ids seen so far, otherwise pages through the whole
  /// favorites list once and remembers every id it passes.
  @override
  FutureEither<bool> isFavorite(String bookId) {
    return _guard(() async {
      if (_knownBookIds.contains(bookId)) return true;
      int pageNumber = 1;
      while (true) {
        final FavoriteBooksPageModel model = await _remoteDataSource
            .getFavoriteBooks(
              pageNumber: pageNumber,
              pageSize: 100,
              searchTerm: '',
            );
        _knownBookIds.addAll(model.items.map((item) => item.bookId));
        if (_knownBookIds.contains(bookId)) return true;
        if (!model.hasNextPage || model.items.isEmpty) return false;
        pageNumber++;
      }
    });
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

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}
