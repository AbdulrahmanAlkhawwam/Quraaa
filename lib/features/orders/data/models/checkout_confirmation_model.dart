import '../../domain/entities/checkout_confirmation.dart';

class CheckoutConfirmationModel {
  const CheckoutConfirmationModel({
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

  factory CheckoutConfirmationModel.fromJson(Map<String, dynamic> json) {
    final Object? paid = json['paid'];
    final Object? pending = json['pending'];
    if (paid is! bool || pending is! bool) {
      throw const FormatException('Invalid checkout confirmation response.');
    }

    return CheckoutConfirmationModel(
      paid: paid,
      pending: pending,
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
    );
  }

  CheckoutConfirmation toEntity() => CheckoutConfirmation(
        paid: paid,
        pending: pending,
        orderId: orderId,
        orderNumber: orderNumber,
        orderStatus: orderStatus,
        paymentStatus: paymentStatus,
      );
}
