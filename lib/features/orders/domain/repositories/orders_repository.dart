import '../../../../core/architecture/result.dart';
import '../entities/account_order.dart';
import '../entities/checkout_confirmation.dart';
import '../entities/order_checkout.dart';
import '../entities/order_checkout_context.dart';

abstract class OrdersRepository {
  Future<Result<AccountOrder>> getOrder(String orderId);

  const OrdersRepository();

  Future<Result<OrderCheckoutContext>> getCheckoutContext();

  Future<Result<OrderCheckout>> createOrder({
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });

  Future<Result<OrderCheckout>> resumePendingOrderCheckout();
  Future<Result<CheckoutConfirmation>> confirmCheckout(String sessionId);

  Future<Result<List<AccountOrder>>> getMyOrders({int pageNumber = 1});

  Future<Result<AccountOrder>> updateShippingLocation({
    required String orderId,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });
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
