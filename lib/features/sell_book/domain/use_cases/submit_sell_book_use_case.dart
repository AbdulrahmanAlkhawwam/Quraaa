import '../../../../core/architecture/result.dart';
import '../entities/sell_book.dart';
import '../repositories/sell_book_repository.dart';

class SubmitSellBookUseCase {
  const SubmitSellBookUseCase(this._repository);

  final SellBookRepository _repository;

  Future<Result<String>> call(SellBookDraft draft) {
    return _repository.submit(draft);
  }
}
