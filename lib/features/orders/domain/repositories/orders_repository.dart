import '../../../../core/architecture/result.dart';
import '../entities/order_checkout.dart';

abstract class OrdersRepository {
  const OrdersRepository();

  Future<Result<OrderCheckout>> createOrder({
    required String successUrl,
    required String cancelUrl,
    double? latitude,
    double? longitude,
  });
}
