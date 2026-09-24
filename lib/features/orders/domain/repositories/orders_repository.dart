import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/account_order.dart';
import '../entities/checkout_confirmation.dart';
import '../entities/order_checkout.dart';
import '../entities/order_checkout_context.dart';

abstract class OrdersRepository {
  const OrdersRepository();

  FutureEither<AccountOrder> getOrder(String orderId);

  /// What the cart can be checked out as: totals, saved locations and whether
  /// a shipping address is required.
  FutureEither<OrderCheckoutContext> getCheckoutContext();

  FutureEither<OrderCheckout> createOrder({
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });

  /// Picks up the payment session of an order that was left unpaid.
  FutureEither<OrderCheckout> resumePendingOrderCheckout();

  FutureEither<CheckoutConfirmation> confirmCheckout(String sessionId);

  FutureEither<List<AccountOrder>> getMyOrders({int pageNumber = 1});

  FutureEither<AccountOrder> updateShippingLocation({
    required String orderId,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });

  FutureEither<Unit> cancelOrder(String orderId, {String? reason});

  FutureEither<List<AccountOrder>> getSellHistory({int pageNumber = 1});

  FutureEither<List<AccountOrder>> getSellerOrders({
    int pageNumber = 1,
    int? fulfillmentStatus,
  });

  FutureEither<Unit> markSellerItemProcessing(
    String orderId,
    String orderItemId,
  );

  FutureEither<Unit> markSellerItemFulfilled(
    String orderId,
    String orderItemId,
  );
}
