import '../../../../core/use_cases/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase extends NoParamsUseCase<CartSummary> {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  FutureEither<CartSummary> call() => _repository.clearCart();
}
