import '../../../../core/architecture/result.dart';
import '../entities/order_checkout.dart';
import '../entities/order_checkout_context.dart';
import '../entities/account_order.dart';

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

  Future<Result<List<AccountOrder>>> getMyOrders({int pageNumber = 1});

  Future<Result<void>> cancelOrder(String orderId, {String? reason});

  Future<Result<List<AccountOrder>>> getSellHistory({int pageNumber = 1});

  Future<Result<List<AccountOrder>>> getSellerOrders({
    int pageNumber = 1,
    int? fulfillmentStatus,
  });

  Future<Result<void>> markSellerItemProcessing(
    String orderId,
    String orderItemId,
  );

  Future<Result<void>> markSellerItemFulfilled(
    String orderId,
    String orderItemId,
  );
}
