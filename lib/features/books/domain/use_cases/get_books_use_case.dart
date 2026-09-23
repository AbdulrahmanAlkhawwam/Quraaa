import '../../../../core/use_cases/use_case.dart';
import '../entities/book.dart';
import '../entities/book_catalog_filter.dart';
import '../repositories/books_repository.dart';

class GetBooksParams {
  const GetBooksParams({
    this.query = '',
    this.format,
    this.catalogFilter = const BookCatalogFilter(),
  });

  final String query;
  final BookFormat? format;
  final BookCatalogFilter catalogFilter;
}

class GetBooksUseCase extends UseCase<List<Book>, GetBooksParams> {
  const GetBooksUseCase(this._repository);

  final BooksRepository _repository;

  @override
  FutureEither<List<Book>> call(GetBooksParams params) => _repository.getBooks(
    query: params.query,
    format: params.format,
    catalogFilter: params.catalogFilter,
  );
}
