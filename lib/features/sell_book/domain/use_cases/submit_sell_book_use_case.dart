import '../entities/sell_book.dart';
import '../repositories/sell_book_repository.dart';

class SubmitSellBookUseCase {
  const SubmitSellBookUseCase(this._repository);
  final SellBookRepository _repository;
  Future<void> call(SellBookDraft draft, {required bool saveAsDraft}) => _repository.submit(draft, saveAsDraft: saveAsDraft);
}
