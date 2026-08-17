import 'package:equatable/equatable.dart';

class CheckoutConfirmation extends Equatable {
  const CheckoutConfirmation({
    required this.paid,
    required this.pending,
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentStatus,
  });

  final bool paid;
  final bool pending;
  final String orderId;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;

  @override
  List<Object?> get props => <Object?>[
        paid,
        pending,
        orderId,
        orderNumber,
        orderStatus,
        paymentStatus,
      ];
}
