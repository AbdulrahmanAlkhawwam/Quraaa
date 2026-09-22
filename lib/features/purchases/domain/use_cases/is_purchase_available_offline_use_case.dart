import '../../../../core/use_cases/use_case.dart';
import '../repositories/purchases_repository.dart';

class IsPurchaseAvailableOfflineUseCase extends UseCase<bool, String> {
  const IsPurchaseAvailableOfflineUseCase(this._repository);

  final PurchasesRepository _repository;

  @override
  FutureEither<bool> call(String params) =>
      _repository.isAvailableOffline(params);
}
