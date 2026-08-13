class CartResponseModel {
  const CartResponseModel({
    required this.cartId,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.itemCount,
    this.stripeCheckoutSessionId,
  });

  final String cartId;
  final int status;
  final List<CartResponseItemModel> items;
  final double totalAmount;
  final int itemCount;
  final String? stripeCheckoutSessionId;

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = json['items'] is List
        ? json['items'] as List<dynamic>
        : const <dynamic>[];
    return CartResponseModel(
      cartId: json['cartId']?.toString() ?? '',
      status: _toInt(json['status']),
      items: rawItems
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> item) => CartResponseItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      totalAmount: _toDouble(json['totalAmount']),
      itemCount: _toInt(json['itemCount']),
      stripeCheckoutSessionId: _toNullableString(
        json['stripeCheckoutSessionId'],
      ),
    );
  }
}

class CartResponseItemModel {
  const CartResponseItemModel({
    required this.listingId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String listingId;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory CartResponseItemModel.fromJson(Map<String, dynamic> json) {
    return CartResponseItemModel(
      listingId: json['listingId']?.toString() ?? '',
      quantity: _toInt(json['quantity']),
      unitPrice: _toDouble(json['unitPrice']),
      lineTotal: _toDouble(json['lineTotal']),
    );
  }
}

int _toInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _toDouble(dynamic value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;

String? _toNullableString(dynamic value) {
  final String text = value?.toString() ?? '';
  return text.isEmpty ? null : text;
}
