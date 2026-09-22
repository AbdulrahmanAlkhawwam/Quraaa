import '../../../../core/use_cases/use_case.dart';
import '../entities/sell_book.dart';
import '../repositories/sell_book_repository.dart';

class FindBookByIsbnUseCase extends UseCase<SellBookPreview?, String> {
  const FindBookByIsbnUseCase(this._repository);

  final SellBookRepository _repository;

  @override
  FutureEither<SellBookPreview?> call(String isbn) =>
      _repository.findByIsbn(isbn);
}
