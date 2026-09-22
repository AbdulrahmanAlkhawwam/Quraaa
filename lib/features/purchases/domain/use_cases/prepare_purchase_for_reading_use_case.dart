import '../../../../core/use_cases/use_case.dart';
import '../entities/prepared_purchase_book.dart';
import '../repositories/purchases_repository.dart';

class PreparePurchaseForReadingUseCase
    extends UseCase<PreparedPurchaseBook, String> {
  const PreparePurchaseForReadingUseCase(this._repository);

  final PurchasesRepository _repository;

  @override
  FutureEither<PreparedPurchaseBook> call(String params) =>
      _repository.prepareForReading(params);
}
