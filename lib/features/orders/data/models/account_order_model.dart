import '../../domain/entities/account_order.dart';

class AccountOrderItemModel extends AccountOrderItem {
  const AccountOrderItemModel({
    required super.orderItemId,
    required super.listingId,
    required super.bookId,
    required super.title,
    required super.author,
    required super.coverImageUrl,
    required super.condition,
    required super.format,
    required super.quantity,
    required super.unitPrice,
    required super.fulfillmentStatus,
  });

  factory AccountOrderItemModel.fromJson(Map<String, dynamic> json) {
    return AccountOrderItemModel(
      orderItemId: _text(json['orderItemId']),
      listingId: _text(json['listingId']),
      bookId: _text(json['bookId']),
      title: _text(json['title']),
      author: _text(json['author'] ?? json['authorName']),
      coverImageUrl: _text(json['coverImageUrl']),
      condition: _text(json['condition']),
      format: _text(json['format'] ?? json['sellerType']),
      quantity: _integer(json['quantity'], fallback: 1),
      unitPrice: _decimal(json['unitPrice'] ?? json['totalPrice']),
      fulfillmentStatus: _fulfillmentStatus(json['fulfillmentStatus']),
    );
  }
}

class AccountOrderModel extends AccountOrder {
  const AccountOrderModel({
    required super.orderId,
    required super.orderNumber,
    required super.status,
    required super.paymentStatus,
    required super.currency,
    required super.totalAmount,
    required super.creationTime,
    required super.items,
    super.isSaleHistory,
  });

  factory AccountOrderModel.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    return AccountOrderModel(
      orderId: _text(json['orderId']),
      orderNumber: _text(json['orderNumber']),
      status: _orderStatus(json['status'] ?? json['orderStatus']),
      paymentStatus: _paymentStatus(json['paymentStatus']),
      currency: _text(json['currency'], fallback: 'USD'),
      totalAmount: _decimal(json['totalAmount']),
      creationTime: _date(json['creationTime'] ?? json['createdAt']),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (Map item) => AccountOrderItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const <AccountOrderItemModel>[],
    );
  }

  factory AccountOrderModel.fromSellHistory(Map<String, dynamic> json) {
    final Map<String, dynamic> book = json['book'] is Map
        ? Map<String, dynamic>.from(json['book'] as Map)
        : const <String, dynamic>{};
    final String purchaseId = _text(json['purchaseId']);
    return AccountOrderModel(
      orderId: purchaseId,
      orderNumber:
          purchaseId.length > 8 ? purchaseId.substring(0, 8) : purchaseId,
      status: 3,
      paymentStatus: 1,
      currency: '',
      totalAmount: _decimal(json['totalEarned']),
      creationTime: _date(json['soldAt']),
      isSaleHistory: true,
      items: <AccountOrderItem>[
        AccountOrderItemModel(
          orderItemId: purchaseId,
          listingId: '',
          bookId: _text(book['bookId']),
          title: _text(book['title']),
          author: _text(book['author']),
          coverImageUrl: _text(book['coverImageUrl']),
          condition: '',
          format: '',
          quantity: _integer(json['quantity'], fallback: 1),
          unitPrice: _decimal(json['unitPrice']),
          fulfillmentStatus: 2,
        ),
      ],
    );
  }

  factory AccountOrderModel.fromSellerItem(Map<String, dynamic> json) {
    return AccountOrderModel(
      orderId: _text(json['orderId']),
      orderNumber: _text(json['orderNumber']),
      status: _orderStatus(json['orderStatus']),
      paymentStatus: _paymentStatus(json['paymentStatus']),
      currency: _text(json['currency'], fallback: 'USD'),
      totalAmount: _decimal(json['lineTotal']),
      creationTime: _date(json['creationTime']),
      items: <AccountOrderItem>[
        AccountOrderItemModel.fromJson(json),
      ],
    );
  }

  AccountOrderModel mergeSellerItem(Map<String, dynamic> json) {
    return AccountOrderModel(
      orderId: orderId,
      orderNumber: orderNumber,
      status: status,
      paymentStatus: paymentStatus,
      currency: currency,
      totalAmount: totalAmount + _decimal(json['lineTotal']),
      creationTime: creationTime,
      items: <AccountOrderItem>[
        ...items,
        AccountOrderItemModel.fromJson(json),
      ],
    );
  }
}

String _text(Object? value, {String fallback = ''}) {
  final String result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

int _integer(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int _orderStatus(Object? value) {
  final int? numeric = _numericEnum(value);
  if (numeric != null) return numeric;
  return switch (_enumName(value)) {
    'processing' || 'confirmed' || 'paid' => 1,
    'shipped' || 'ondelivery' || 'outfordelivery' => 2,
    'completed' || 'delivered' || 'fulfilled' => 3,
    'cancelled' || 'canceled' || 'expired' || 'failed' || 'rejected' => 4,
    _ => 0,
  };
}

int _paymentStatus(Object? value) {
  final int? numeric = _numericEnum(value);
  if (numeric != null) return numeric;
  return switch (_enumName(value)) {
    'paid' || 'completed' || 'succeeded' => 1,
    'failed' || 'rejected' => 2,
    'expired' || 'cancelled' || 'canceled' => 3,
    'refunded' => 4,
    _ => 0,
  };
}

int _fulfillmentStatus(Object? value) {
  final int? numeric = _numericEnum(value);
  if (numeric != null) return numeric;
  return switch (_enumName(value)) {
    'processing' => 1,
    'fulfilled' || 'completed' || 'delivered' => 2,
    'rejected' || 'cancelled' || 'canceled' || 'expired' => 3,
    _ => 0,
  };
}

int? _numericEnum(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String _enumName(Object? value) =>
    value?.toString().trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '') ??
    '';
double _decimal(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');
