import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.fileSize,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  final String id;
  final String title;
  final String subtitle;
  final String fileSize;
  final String imageUrl;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? fileSize,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      fileSize: fileSize ?? this.fileSize,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
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
      ];
}

