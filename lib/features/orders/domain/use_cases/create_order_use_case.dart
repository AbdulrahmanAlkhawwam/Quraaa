import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/order_checkout.dart';
import '../repositories/orders_repository.dart';

class CreateOrderUseCase
    extends UseCase<Result<OrderCheckout>, CreateOrderParams> {
  const CreateOrderUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<OrderCheckout>> call(CreateOrderParams params) {
    return _repository.createOrder(
      successUrl: params.successUrl,
      cancelUrl: params.cancelUrl,
      shippingLocationId: params.shippingLocationId,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class CreateOrderParams extends Equatable {
  const CreateOrderParams({
    required this.successUrl,
    required this.cancelUrl,
    this.shippingLocationId,
    this.latitude,
    this.longitude,
  });

  final String successUrl;
  final String cancelUrl;
  final String? shippingLocationId;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => <Object?>[
        successUrl,
        cancelUrl,
        shippingLocationId,
        latitude,
        longitude,
      ];
}
