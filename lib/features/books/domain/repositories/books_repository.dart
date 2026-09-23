import '../../../../core/use_cases/use_case.dart';
import '../entities/book.dart';
import '../entities/book_catalog_filter.dart';

abstract interface class BooksRepository {
  /// The catalog for [catalogFilter], narrowed by a free-text [query] and an
  /// optional [format].
  FutureEither<List<Book>> getBooks({
    String query,
    BookFormat? format,
    BookCatalogFilter catalogFilter,
  });
}
