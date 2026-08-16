import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/order_checkout.dart';
import '../repositories/orders_repository.dart';

class ResumePendingOrderCheckoutUseCase
    extends UseCase<Result<OrderCheckout>, ResumePendingOrderCheckoutParams> {
  const ResumePendingOrderCheckoutUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<OrderCheckout>> call(ResumePendingOrderCheckoutParams params) {
    return _repository.resumePendingOrderCheckout(
      successUrl: params.successUrl,
      cancelUrl: params.cancelUrl,
    );
  }
}

class ResumePendingOrderCheckoutParams extends Equatable {
  const ResumePendingOrderCheckoutParams({
    required this.successUrl,
    required this.cancelUrl,
  });

  final String successUrl;
  final String cancelUrl;

  @override
  List<Object> get props => <Object>[successUrl, cancelUrl];
}
