import '../../../../core/use_cases/use_case.dart';
import '../entities/cart_item.dart';
import '../entities/cart_summary.dart';

abstract class CartRepository {
  const CartRepository();

  FutureEither<CartSummary> getCart();

  FutureEither<CartSummary> clearCart();

  FutureEither<CartSummary> addItem({
    required String listingId,
    required int quantity,
    CartItem? metadata,
  });

  FutureEither<CartSummary> updateQuantity({
    required String listingId,
    required int quantity,
  });

  FutureEither<CartSummary> removeItem(String listingId);
}
