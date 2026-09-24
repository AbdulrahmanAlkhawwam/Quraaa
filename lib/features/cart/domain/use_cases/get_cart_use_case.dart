import '../../../../core/use_cases/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase extends NoParamsUseCase<CartSummary> {
  const GetCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  FutureEither<CartSummary> call() {
    return _repository.getCart();
  }
}

