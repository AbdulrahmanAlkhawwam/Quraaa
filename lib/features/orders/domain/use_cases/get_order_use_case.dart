import 'package:equatable/equatable.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/account_order.dart';
import '../repositories/orders_repository.dart';

class GetOrderUseCase extends UseCase<AccountOrder, GetOrderParams> {
  const GetOrderUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  FutureEither<AccountOrder> call(GetOrderParams params) {
    return _repository.getOrder(params.orderId);
  }
}

class GetOrderParams extends Equatable {
  const GetOrderParams(this.orderId);

  final String orderId;

  @override
  List<Object> get props => <Object>[orderId];
}
