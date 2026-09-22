import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/purchases_repository.dart';

class DownloadPurchaseForOfflineUseCase extends UseCase<Unit, String> {
  const DownloadPurchaseForOfflineUseCase(this._repository);

  final PurchasesRepository _repository;

  @override
  FutureEither<Unit> call(String params) =>
      _repository.downloadForOffline(params);
}
