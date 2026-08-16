import '../../domain/entities/order_checkout.dart';

class OrderCheckoutModel {
  const OrderCheckoutModel({
    required this.orderId,
    required this.orderNumber,
    required this.paymentAttemptId,
    required this.checkoutSessionId,
    required this.checkoutUrl,
    required this.expiresAt,
  });

  final String orderId;
  final String orderNumber;
  final String paymentAttemptId;
  final String checkoutSessionId;
  final String checkoutUrl;
  final DateTime? expiresAt;

  factory OrderCheckoutModel.fromJson(Map<String, dynamic> json) {
    final Object? rawOrder = json['order'];
    final Map<String, dynamic> order = rawOrder is Map
        ? Map<String, dynamic>.from(rawOrder)
        : const <String, dynamic>{};
    return OrderCheckoutModel(
      orderId: order['orderId']?.toString() ?? '',
      orderNumber: order['orderNumber']?.toString() ?? '',
      paymentAttemptId: json['paymentAttemptId']?.toString() ?? '',
      checkoutSessionId: json['checkoutSessionId']?.toString() ?? '',
      checkoutUrl: json['checkoutUrl']?.toString() ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
    );
  }

  OrderCheckout toEntity() => OrderCheckout(
        orderId: orderId,
        orderNumber: orderNumber,
        paymentAttemptId: paymentAttemptId,
        checkoutSessionId: checkoutSessionId,
        checkoutUrl: checkoutUrl,
        expiresAt: expiresAt,
      );
}
