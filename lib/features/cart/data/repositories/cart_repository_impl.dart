import '../../../../core/architecture/result.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl extends CartRepository {
  CartRepositoryImpl() : _summary = _buildInitialSummary();

  CartSummary _summary;

  static const String _bookImageUrl =
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=240&q=80';
  static const String _avatarUrl = 'https://i.pravatar.cc/96?img=12';

  static CartSummary _buildInitialSummary() {
    const List<CartItem> items = <CartItem>[
      CartItem(
        id: 'emar-1',
        title: 'Emar English book',
        subtitle: 'syrian republic arabic gov',
        fileSize: '3.5 KB',
        imageUrl: _bookImageUrl,
        unitPrice: 6.3333333333,
        quantity: 2,
      ),
      CartItem(
        id: 'emar-2',
        title: 'Emar English book',
        subtitle: 'syrian republic arabic gov',
        fileSize: '3.5 KB',
        imageUrl: _bookImageUrl,
        unitPrice: 6.3333333333,
        quantity: 2,
      ),
      CartItem(
        id: 'emar-3',
        title: 'Emar English book',
        subtitle: 'syrian republic arabic gov',
        fileSize: '3.5 KB',
        imageUrl: _bookImageUrl,
        unitPrice: 6.3333333333,
        quantity: 2,
      ),
    ];

    return _summaryFromItems(
      items: items,
      couponCode: '58241',
      couponApplied: true,
    );
  }

  static CartSummary _summaryFromItems({
    required List<CartItem> items,
    required String couponCode,
    required bool couponApplied,
  }) {
    final double subtotal = items.fold<double>(
      0,
      (double value, CartItem item) => value + item.lineTotal,
    );
    const double fatPercent = 3;
    const double delivery = 7.5;
    const double discountPercent = 15;
    final double total = subtotal + delivery + (subtotal * fatPercent / 100) -
        (couponApplied ? 0.84 : 0);

    return CartSummary(
      userName: 'Abdulrahman',
      avatarUrl: _avatarUrl,
      items: List<CartItem>.unmodifiable(items),
      couponCode: couponCode,
      couponApplied: couponApplied,
      subtotal: subtotal,
      fatPercent: fatPercent,
      delivery: delivery,
      discountPercent: discountPercent,
      total: total,
    );
  }

  CartSummary _recalculate(List<CartItem> items) {
    return _summaryFromItems(
      items: items,
      couponCode: _summary.couponCode,
      couponApplied: _summary.couponApplied,
    );
  }

  @override
  Future<Result<CartSummary>> getCart() async {
    return Success<CartSummary>(_summary);
  }

  @override
  Future<Result<CartSummary>> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final int nextQuantity = quantity.clamp(1, 99).toInt();
    final List<CartItem> updated = _summary.items.map((CartItem item) {
      return item.id == itemId ? item.copyWith(quantity: nextQuantity) : item;
    }).toList(growable: false);
    _summary = _recalculate(updated);
    return Success<CartSummary>(_summary);
  }

  @override
  Future<Result<CartSummary>> removeItem(String itemId) async {
    final List<CartItem> updated = _summary.items
        .where((CartItem item) => item.id != itemId)
        .toList(growable: false);
    _summary = _recalculate(updated);
    return Success<CartSummary>(_summary);
  }

  @override
  Future<Result<CartSummary>> applyCoupon(String code) async {
    final String normalized = code.trim().isEmpty ? _summary.couponCode : code;
    _summary = _summaryFromItems(
      items: _summary.items,
      couponCode: normalized,
      couponApplied: true,
    );
    return Success<CartSummary>(_summary);
  }
}

