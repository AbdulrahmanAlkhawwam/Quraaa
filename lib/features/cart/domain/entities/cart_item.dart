import 'package:equatable/equatable.dart';

enum CartItemStatus { available, priceChanged, unavailable }

class CartItem extends Equatable {
  const CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.fileSize,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    this.status = CartItemStatus.available,
  });

  final String id;
  final String title;
  final String subtitle;
  final String fileSize;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final CartItemStatus status;

  bool get isAvailable => status != CartItemStatus.unavailable;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? fileSize,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
    CartItemStatus? status,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      fileSize: fileSize ?? this.fileSize,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        subtitle,
        fileSize,
        imageUrl,
        unitPrice,
        quantity,
        status,
      ];
}

