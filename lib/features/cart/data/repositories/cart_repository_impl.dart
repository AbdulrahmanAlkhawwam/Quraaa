import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_response_model.dart';

class CartRepositoryImpl extends CartRepository {
  const CartRepositoryImpl(this._remoteDataSource);

  final CartRemoteDataSource _remoteDataSource;

  @override
  Future<Result<CartSummary>> getCart() => _execute(_remoteDataSource.getCart);

  @override
  Future<Result<CartSummary>> addItem({
    required String listingId,
    required int quantity,
  }) => _execute(
    () => _remoteDataSource.addItem(listingId: listingId, quantity: quantity),
  );

  @override
  Future<Result<CartSummary>> updateQuantity({
    required String itemId,
    required int quantity,
  }) => _execute(
    () => _remoteDataSource.updateQuantity(
      listingId: itemId,
      quantity: quantity,
    ),
  );

  @override
  Future<Result<CartSummary>> removeItem(String itemId) =>
      _execute(() => _remoteDataSource.removeItem(itemId));

  @override
  Future<Result<CartSummary>> clearCart() => _execute(
    _remoteDataSource.clearCart,
  );

  @override
  Future<Result<CartSummary>> applyCoupon(String code) => getCart();

  Future<Result<CartSummary>> _execute(
    Future<CartResponseModel> Function() operation,
  ) async {
    try {
      return Success<CartSummary>(_toSummary(await operation()));
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<CartSummary>(failure.message, cause: failure);
    }
  }

  CartSummary _toSummary(CartResponseModel response) {
    final List<CartItem> items = response.items
        .where((CartResponseItemModel item) => item.listingId.isNotEmpty)
        .map(
          (CartResponseItemModel item) => CartItem(
            id: item.listingId,
            title: 'Listing ${item.listingId}',
            subtitle: '',
            fileSize: '',
            imageUrl: '',
            unitPrice: item.unitPrice,
            quantity: item.quantity,
            status: item.quantity == 0
                ? CartItemStatus.unavailable
                : CartItemStatus.available,
          ),
        )
        .toList(growable: false);

    return CartSummary(
      userName: '',
      avatarUrl: '',
      items: items,
      couponCode: '',
      couponApplied: false,
      subtotal: response.totalAmount,
      fatPercent: 0,
      delivery: 0,
      discountPercent: 0,
      total: response.totalAmount,
    );
  }
}
