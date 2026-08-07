class CartResponseModel {
  const CartResponseModel({
    required this.cartId,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.itemCount,
    required this.stripeCheckoutSessionId,
  });

  final String cartId;
  final String status;
  final List<CartItemResponseModel> items;
  final double totalAmount;
  final int itemCount;
  final String? stripeCheckoutSessionId;

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    return CartResponseModel(
      cartId: json['cartId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (Map item) => CartItemResponseModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const <CartItemResponseModel>[],
      totalAmount: _asDouble(json['totalAmount']),
      itemCount: _asInt(json['itemCount']),
      stripeCheckoutSessionId: json['stripeCheckoutSessionId']?.toString(),
    );
  }
}

class CartItemResponseModel {
  const CartItemResponseModel({
    required this.listingId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.title = '',
    this.subtitle = '',
    this.coverImageUrl = '',
    this.fileSize = '',
  });

  final String listingId;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String title;
  final String subtitle;
  final String coverImageUrl;
  final String fileSize;

  factory CartItemResponseModel.fromJson(Map<String, dynamic> json) {
    return CartItemResponseModel(
      listingId: json['listingId']?.toString() ?? '',
      quantity: _asInt(json['quantity']),
      unitPrice: _asDouble(json['unitPrice']),
      lineTotal: _asDouble(json['lineTotal']),
      title: json['title']?.toString() ?? '',
      subtitle:
          (json['author'] ?? json['subtitle'] ?? json['publisher'])
              ?.toString() ??
          '',
      coverImageUrl:
          (json['coverImageUrl'] ?? json['imageUrl'])?.toString() ?? '',
      fileSize: json['fileSize']?.toString() ?? '',
    );
  }
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
