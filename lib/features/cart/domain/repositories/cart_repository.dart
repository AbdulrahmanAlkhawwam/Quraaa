import '../../../../core/architecture/result.dart';
import '../entities/cart_item.dart';
import '../entities/cart_summary.dart';

abstract class CartRepository {
  const CartRepository();

  Future<Result<CartSummary>> getCart();

  Future<Result<CartSummary>> clearCart();


  Future<Result<CartSummary>> addItem({
    required String listingId,
    required int quantity,
  });

  Future<Result<CartSummary>> updateQuantity({
    required String itemId,
    required int quantity,
    CartItem? metadata,
  });

  Future<Result<CartSummary>> updateQuantity({
    required String listingId,
    required int quantity,
  });

  Future<Result<CartSummary>> removeItem(String listingId);
  Future<Result<CartSummary>> clearCart();

  Future<Result<CartSummary>> applyCoupon(String code);
}
