import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase extends UseCase<Result<CartSummary>, NoParams> {
  const GetCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(NoParams params) {
    return _repository.getCart();
  }
}

