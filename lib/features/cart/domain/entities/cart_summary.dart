import 'package:equatable/equatable.dart';

import 'cart_item.dart';

class CartSummary extends Equatable {
  const CartSummary({
    this.cartId = '',
    this.status = '',
    this.stripeCheckoutSessionId,
    this.itemCount = 0,
    required this.userName,
    required this.avatarUrl,
    required this.items,
    required this.couponCode,
    required this.couponApplied,
    required this.subtotal,
    required this.fatPercent,
    required this.delivery,
    required this.discountPercent,
    required this.total,
  });

  final String cartId;
  final String status;
  final String? stripeCheckoutSessionId;
  final int itemCount;
  final String userName;
  final String avatarUrl;
  final List<CartItem> items;
  final String couponCode;
  final bool couponApplied;
  final double subtotal;
  final double fatPercent;
  final double delivery;
  final double discountPercent;
  final double total;

  CartSummary copyWith({
    String? cartId,
    String? status,
    String? stripeCheckoutSessionId,
    int? itemCount,
    String? userName,
    String? avatarUrl,
    List<CartItem>? items,
    String? couponCode,
    bool? couponApplied,
    double? subtotal,
    double? fatPercent,
    double? delivery,
    double? discountPercent,
    double? total,
  }) {
    return CartSummary(
      cartId: cartId ?? this.cartId,
      status: status ?? this.status,
      stripeCheckoutSessionId:
          stripeCheckoutSessionId ?? this.stripeCheckoutSessionId,
      itemCount: itemCount ?? this.itemCount,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      couponApplied: couponApplied ?? this.couponApplied,
      subtotal: subtotal ?? this.subtotal,
      fatPercent: fatPercent ?? this.fatPercent,
      delivery: delivery ?? this.delivery,
      discountPercent: discountPercent ?? this.discountPercent,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    cartId,
    status,
    stripeCheckoutSessionId,
    itemCount,
    userName,
    avatarUrl,
    items,
    couponCode,
    couponApplied,
    subtotal,
    fatPercent,
    delivery,
    discountPercent,
    total,
  ];
}
