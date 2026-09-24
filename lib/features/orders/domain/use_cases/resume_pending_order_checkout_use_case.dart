import '../../../../core/use_cases/use_case.dart';
import '../entities/order_checkout.dart';
import '../repositories/orders_repository.dart';

class ResumePendingOrderCheckoutUseCase
    extends NoParamsUseCase<OrderCheckout> {
  const ResumePendingOrderCheckoutUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  FutureEither<OrderCheckout> call() {
    return _repository.resumePendingOrderCheckout();
  }
}
