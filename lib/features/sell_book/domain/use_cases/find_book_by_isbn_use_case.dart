import '../entities/sell_book.dart';
import '../repositories/sell_book_repository.dart';

class FindBookByIsbnUseCase {
  const FindBookByIsbnUseCase(this._repository);
  final SellBookRepository _repository;
  Future<SellBookPreview?> call(String isbn) => _repository.findByIsbn(isbn);
}
