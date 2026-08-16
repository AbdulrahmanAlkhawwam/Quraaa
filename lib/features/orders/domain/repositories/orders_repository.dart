import '../../../../core/architecture/result.dart';
import '../entities/order_checkout.dart';
import '../entities/order_checkout_context.dart';

abstract class OrdersRepository {
  const OrdersRepository();

  Future<Result<OrderCheckoutContext>> getCheckoutContext();

  Future<Result<OrderCheckout>> createOrder({
    required String successUrl,
    required String cancelUrl,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });

  Future<Result<OrderCheckout>> resumePendingOrderCheckout({
    required String successUrl,
    required String cancelUrl,
  });
}
