import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_catalog_filter.dart';
import '../../domain/repositories/books_repository.dart';
import '../data_sources/books_remote_data_source.dart';
import '../models/home_catalog_book_model.dart';

class BooksRepositoryImpl implements BooksRepository {
  BooksRepositoryImpl(this._remoteDataSource);

  final BooksRemoteDataSource _remoteDataSource;

  @override
  FutureEither<List<Book>> getBooks({
    String query = '',
    BookFormat? format,
    BookCatalogFilter catalogFilter = const BookCatalogFilter(),
  }) async {
    try {
      final List<Book> books = await _loadCatalog(catalogFilter, query);
      final String normalizedQuery = query.trim().toLowerCase();

      return Right(
        books.where((Book book) {
          final bool matchesQuery =
              normalizedQuery.isEmpty ||
              book.title.toLowerCase().contains(normalizedQuery) ||
              book.subtitle.toLowerCase().contains(normalizedQuery) ||
              book.author.toLowerCase().contains(normalizedQuery);
          final bool matchesFormat = format == null || book.format == format;
          return matchesQuery && matchesFormat;
        }).toList(growable: false),
      );
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  Future<List<Book>> _loadCatalog(
    BookCatalogFilter filter,
    String query,
  ) async {
    final List<HomeCatalogBookModel> models = await _remoteDataSource
        .fetchHomeCatalog(filter: filter, query: query);
    return models
        .map((HomeCatalogBookModel model) => model.toEntity())
        .toList(growable: false);
  }
}
