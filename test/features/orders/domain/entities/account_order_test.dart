import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/orders/domain/entities/account_order.dart';

void main() {
  group('AccountOrder.stage', () {
    test('uses item processing when the order status is still pending', () {
      final AccountOrder order =
          _order(status: 0, fulfillmentStatuses: <int>[1]);

      expect(order.stage, AccountOrderStage.processing);
    });

    test('uses fulfilled items when the order status is still pending', () {
      final AccountOrder order =
          _order(status: 0, fulfillmentStatuses: <int>[2]);

      expect(order.stage, AccountOrderStage.onDelivery);
    });

    test('keeps the most advanced order status', () {
      final AccountOrder order =
          _order(status: 3, fulfillmentStatuses: <int>[1]);

      expect(order.stage, AccountOrderStage.onDoor);
    });

    test('treats an entirely rejected order as cancelled', () {
      final AccountOrder order =
          _order(status: 0, fulfillmentStatuses: <int>[3]);

      expect(order.stage, AccountOrderStage.cancelled);
    });
  });
}

AccountOrder _order({
  required int status,
  required List<int> fulfillmentStatuses,
}) {
  return AccountOrder(
    orderId: 'order-id',
    orderNumber: '123',
    status: status,
    paymentStatus: 1,
    currency: 'USD',
    totalAmount: 10,
    creationTime: DateTime(2026),
    items: fulfillmentStatuses
        .map(
          (int fulfillmentStatus) => AccountOrderItem(
            orderItemId: 'item-$fulfillmentStatus',
            listingId: 'listing-id',
            bookId: 'book-id',
            title: 'Book',
            author: 'Author',
            coverImageUrl: '',
            condition: '',
            format: 'Physical',
            quantity: 1,
            unitPrice: 10,
            fulfillmentStatus: fulfillmentStatus,
          ),
        )
        .toList(growable: false),
  );
}
