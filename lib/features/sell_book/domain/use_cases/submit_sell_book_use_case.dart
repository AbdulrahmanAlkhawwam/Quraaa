import '../../../../core/use_cases/use_case.dart';
import '../entities/sell_book.dart';
import '../repositories/sell_book_repository.dart';

class SubmitSellBookUseCase extends UseCase<String, SellBookDraft> {
  const SubmitSellBookUseCase(this._repository);

  final SellBookRepository _repository;

  @override
  FutureEither<String> call(SellBookDraft draft) => _repository.submit(draft);
}
