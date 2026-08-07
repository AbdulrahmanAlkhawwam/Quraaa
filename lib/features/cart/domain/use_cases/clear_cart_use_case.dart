import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase extends UseCase<Result<CartSummary>, NoParams> {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(NoParams params) => _repository.clearCart();
}
