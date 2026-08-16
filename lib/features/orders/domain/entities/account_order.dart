import 'package:equatable/equatable.dart';

enum AccountOrderStage { pending, processing, onDelivery, onDoor, cancelled }

class AccountOrderItem extends Equatable {
  const AccountOrderItem({
    required this.orderItemId,
    required this.listingId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.condition,
    required this.format,
    required this.quantity,
    required this.unitPrice,
    required this.fulfillmentStatus,
  });

  final String orderItemId;
  final String listingId;
  final String bookId;
  final String title;
  final String author;
  final String coverImageUrl;
  final String condition;
  final String format;
  final int quantity;
  final double unitPrice;
  final int fulfillmentStatus;

  @override
  List<Object?> get props => <Object?>[
        orderItemId,
        listingId,
        bookId,
        title,
        author,
        coverImageUrl,
        condition,
        format,
        quantity,
        unitPrice,
        fulfillmentStatus,
      ];
}

class AccountOrder extends Equatable {
  const AccountOrder({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.currency,
    required this.totalAmount,
    required this.creationTime,
    required this.items,
    this.isSaleHistory = false,
  });

  final String orderId;
  final String orderNumber;
  final int status;
  final int paymentStatus;
  final String currency;
  final double totalAmount;
  final DateTime? creationTime;
  final List<AccountOrderItem> items;
  final bool isSaleHistory;

  AccountOrderStage get stage {
    final AccountOrderStage orderStage = _stageFromOrderStatus(status);
    final AccountOrderStage? fulfillmentStage =
        _stageFromFulfillmentStatuses(items);

    if (orderStage == AccountOrderStage.cancelled ||
        fulfillmentStage == AccountOrderStage.cancelled) {
      return AccountOrderStage.cancelled;
    }
    if (fulfillmentStage == null) return orderStage;

    return orderStage.index >= fulfillmentStage.index
        ? orderStage
        : fulfillmentStage;
  }

  @override
  List<Object?> get props => <Object?>[
        orderId,
        orderNumber,
        status,
        paymentStatus,
        currency,
        totalAmount,
        creationTime,
        items,
      ];
}

AccountOrderStage _stageFromOrderStatus(int status) {
  if (status < 0 || status >= 4) return AccountOrderStage.cancelled;
  return AccountOrderStage.values[status];
}

AccountOrderStage? _stageFromFulfillmentStatuses(
  List<AccountOrderItem> items,
) {
  if (items.isEmpty) return null;

  final List<int> statuses = items
      .map((AccountOrderItem item) => item.fulfillmentStatus)
      .toList(growable: false);
  if (statuses.every((int status) => status == 3)) {
    return AccountOrderStage.cancelled;
  }
  if (statuses.every((int status) => status == 2)) {
    return AccountOrderStage.onDelivery;
  }
  if (statuses.any((int status) => status == 1 || status == 2)) {
    return AccountOrderStage.processing;
  }
  return AccountOrderStage.pending;
}
