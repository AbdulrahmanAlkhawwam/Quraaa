import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/order_checkout.dart';
import '../repositories/orders_repository.dart';

class ResumePendingOrderCheckoutUseCase
    extends UseCase<Result<OrderCheckout>, NoParams> {
  const ResumePendingOrderCheckoutUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<OrderCheckout>> call(NoParams params) {
    return _repository.resumePendingOrderCheckout();
  }
}
