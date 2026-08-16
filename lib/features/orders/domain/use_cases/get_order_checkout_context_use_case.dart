import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/order_checkout_context.dart';
import '../repositories/orders_repository.dart';

class GetOrderCheckoutContextUseCase
    extends UseCase<Result<OrderCheckoutContext>, NoParams> {
  const GetOrderCheckoutContextUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<OrderCheckoutContext>> call(NoParams params) {
    return _repository.getCheckoutContext();
  }
}
