import '../../../../core/use_cases/use_case.dart';
import '../entities/purchase_book_session.dart';
import '../repositories/purchases_repository.dart';

class OpenPurchaseForReadingUseCase
    extends UseCase<PurchaseBookSession, String> {
  const OpenPurchaseForReadingUseCase(this._repository);

  final PurchasesRepository _repository;

  @override
  FutureEither<PurchaseBookSession> call(String params) =>
      _repository.openForReading(params);
}
