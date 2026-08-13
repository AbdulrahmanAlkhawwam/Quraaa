import '../entities/book.dart';
import '../repositories/books_repository.dart';

class GetBooksUseCase {
  const GetBooksUseCase(this._repository);

  final BooksRepository _repository;

  Future<List<Book>> call({String query = '', BookFormat? format}) =>
      _repository.getBooks(query: query, format: format);
}
