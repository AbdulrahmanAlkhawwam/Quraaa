import '../entities/book.dart';
import '../entities/book_catalog_filter.dart';
import '../repositories/books_repository.dart';

class GetBooksUseCase {
  const GetBooksUseCase(this._repository);

  final BooksRepository _repository;

  Future<List<Book>> call({
    String query = '',
    BookFormat? format,
    BookCatalogFilter catalogFilter = const BookCatalogFilter(),
  }) =>
      _repository.getBooks(
        query: query,
        format: format,
        catalogFilter: catalogFilter,
      );
}
