import '../../../../core/use_cases/use_case.dart';
import '../entities/purchased_book.dart';
import '../repositories/purchases_repository.dart';

class GetPurchasedBooksUseCase extends UseCase<List<PurchasedBook>, String> {
  const GetPurchasedBooksUseCase(this._repository);

  final PurchasesRepository _repository;

  @override
  FutureEither<List<PurchasedBook>> call(String params) =>
      _repository.getLibrary(query: params);
}
