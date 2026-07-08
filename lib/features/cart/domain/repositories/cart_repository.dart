import '../../../../core/architecture/result.dart';
import '../entities/cart_summary.dart';

abstract class CartRepository {
  const CartRepository();

  Future<Result<CartSummary>> getCart();

  Future<Result<CartSummary>> updateQuantity({
    required String itemId,
    required int quantity,
  });

  Future<Result<CartSummary>> removeItem(String itemId);

  Future<Result<CartSummary>> applyCoupon(String code);
}

