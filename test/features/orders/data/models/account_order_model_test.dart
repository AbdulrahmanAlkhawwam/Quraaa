import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/orders/data/models/account_order_model.dart';
import 'package:quraaa/features/orders/domain/entities/account_order.dart';

void main() {
  group('AccountOrderModel string enum parsing', () {
    test('maps Processing to the processing stage', () {
      final AccountOrderModel order = AccountOrderModel.fromJson(
        _summary(status: 'Processing'),
      );

      expect(order.status, 1);
      expect(order.paymentStatus, 1);
      expect(order.stage, AccountOrderStage.processing);
    });

    test('maps Completed to the on-door stage', () {
      final AccountOrderModel order = AccountOrderModel.fromJson(
        _summary(status: 'Completed'),
      );

      expect(order.status, 3);
      expect(order.stage, AccountOrderStage.onDoor);
    });

    test('maps Expired to cancelled', () {
      final AccountOrderModel order = AccountOrderModel.fromJson(
        _summary(status: 'Expired', paymentStatus: 'Expired'),
      );

      expect(order.status, 4);
      expect(order.paymentStatus, 3);
      expect(order.stage, AccountOrderStage.cancelled);
    });

    test('maps string fulfillment status from order details', () {
      final Map<String, dynamic> json = _summary(status: 'Pending');
      json['items'] = <Map<String, dynamic>>[
        <String, dynamic>{
          'orderItemId': 'item-id',
          'fulfillmentStatus': 'Fulfilled',
        },
      ];

      final AccountOrderModel order = AccountOrderModel.fromJson(json);

      expect(order.items.single.fulfillmentStatus, 2);
      expect(order.stage, AccountOrderStage.onDelivery);
    });
  });
  group('AccountOrderModel sell history parsing', () {
    test('parses the documented sell-history response', () {
      final AccountOrderModel order = AccountOrderModel.fromSellHistory(
        <String, dynamic>{
          'purchaseId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          'book': <String, dynamic>{
            'bookId': 'book-id',
            'title': 'Book title',
            'author': 'Author name',
            'coverImageUrl': 'https://example.com/cover.jpg',
          },
          'quantity': '2',
          'unitPrice': '12.50',
          'totalEarned': '25.00',
          'buyerUserId': 'buyer-id',
          'soldAt': '2026-08-16T20:43:12.149Z',
        },
      );

      expect(order.isSaleHistory, isTrue);
      expect(order.currency, isEmpty);
      expect(order.totalAmount, 25);
      expect(order.items.single.quantity, 2);
      expect(order.items.single.unitPrice, 12.5);
      expect(order.items.single.title, 'Book title');
      expect(order.items.single.author, 'Author name');
      expect(order.creationTime, DateTime.parse('2026-08-16T20:43:12.149Z'));
    });
  });
}

Map<String, dynamic> _summary({
  required String status,
  String paymentStatus = 'Paid',
}) {
  return <String, dynamic>{
    'orderId': 'dbfe00fc-bb7d-4603-93e9-298641ca984d',
    'orderNumber': 'ORD-20260816-C2D4038E65F7',
    'status': status,
    'paymentStatus': paymentStatus,
    'currency': 'usd',
    'totalAmount': 77,
    'creationTime': '2026-08-16T18:39:54.56301Z',
    'items': <Map<String, dynamic>>[],
  };
}
