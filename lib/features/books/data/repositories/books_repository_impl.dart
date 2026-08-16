import '../../domain/entities/book.dart';
import '../../domain/entities/book_catalog_filter.dart';
import '../../domain/repositories/books_repository.dart';
import '../datasources/books_remote_data_source.dart';
import '../models/home_catalog_book_model.dart';

class BooksRepositoryImpl implements BooksRepository {
  BooksRepositoryImpl(this._remoteDataSource);

  final BooksRemoteDataSource _remoteDataSource;

  @override
  Future<List<Book>> getBooks({
    String query = '',
    BookFormat? format,
    BookCatalogFilter catalogFilter = const BookCatalogFilter(),
  }) async {
    final List<Book> books = await _loadCatalog(catalogFilter);
    final String normalizedQuery = query.trim().toLowerCase();

    return books.where((Book book) {
      final bool matchesQuery = normalizedQuery.isEmpty ||
          book.title.toLowerCase().contains(normalizedQuery) ||
          book.subtitle.toLowerCase().contains(normalizedQuery) ||
          book.author.toLowerCase().contains(normalizedQuery);
      final bool matchesFormat = format == null || book.format == format;
      return matchesQuery && matchesFormat;
    }).toList(growable: false);
  }

  Future<List<Book>> _loadCatalog(BookCatalogFilter filter) async {
    final List<HomeCatalogBookModel> models =
        await _remoteDataSource.fetchHomeCatalog(filter: filter);
    return models
        .map((HomeCatalogBookModel model) => model.toEntity())
        .toList(growable: false);
  }
}
