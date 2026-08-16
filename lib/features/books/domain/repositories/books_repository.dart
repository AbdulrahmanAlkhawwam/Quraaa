import '../entities/book.dart';
import '../entities/book_catalog_filter.dart';

abstract interface class BooksRepository {
  Future<List<Book>> getBooks({
    String query,
    BookFormat? format,
    BookCatalogFilter catalogFilter,
  });
}
