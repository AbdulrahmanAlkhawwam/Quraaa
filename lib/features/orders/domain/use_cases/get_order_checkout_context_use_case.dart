import '../../../../core/use_cases/use_case.dart';
import '../entities/order_checkout_context.dart';
import '../repositories/orders_repository.dart';

class GetOrderCheckoutContextUseCase
    extends NoParamsUseCase<OrderCheckoutContext> {
  const GetOrderCheckoutContextUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  FutureEither<OrderCheckoutContext> call() {
    return _repository.getCheckoutContext();
  }
}
