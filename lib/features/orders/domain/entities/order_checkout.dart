import 'package:equatable/equatable.dart';

class OrderCheckout extends Equatable {
  const OrderCheckout({
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

  @override
  List<Object?> get props => <Object?>[
    orderId,
    orderNumber,
    paymentAttemptId,
    checkoutSessionId,
    checkoutUrl,
    expiresAt,
  ];
}
