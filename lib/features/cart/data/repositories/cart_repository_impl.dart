import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_response_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remoteDataSource);

  final CartRemoteDataSource _remoteDataSource;
  final Map<String, CartItem> _metadataByListingId = <String, CartItem>{};

  @override
  Future<Result<CartSummary>> getCart() => _request(_remoteDataSource.getCart);

  @override
  Future<Result<CartSummary>> clearCart() =>
      _request(_remoteDataSource.clearCart, clearMetadata: true);

  @override
  Future<Result<CartSummary>> addItem({
    required String listingId,
    required int quantity,
    CartItem? metadata,
  }) {
    if (metadata != null) {
      _metadataByListingId[listingId] = metadata;
    }
    return _request(
      () => _remoteDataSource.addItem(listingId: listingId, quantity: quantity),
    );
  }

  @override
  Future<Result<CartSummary>> updateQuantity({
    required String listingId,
    required int quantity,
  }) {
    return _request(
      () => _remoteDataSource.updateQuantity(
        listingId: listingId,
        quantity: quantity,
      ),
    );
  }

  @override
  Future<Result<CartSummary>> removeItem(String listingId) async {
    final Result<CartSummary> result = await _request(
      () => _remoteDataSource.removeItem(listingId),
    );
    if (result is Success<CartSummary>) {
      _metadataByListingId.remove(listingId);
    }
    return result;
  }

  Future<Result<CartSummary>> _request(
    Future<CartResponseModel> Function() request, {
    bool clearMetadata = false,
  }) async {
    try {
      final CartResponseModel response = await request();
      if (clearMetadata) _metadataByListingId.clear();
      return Success<CartSummary>(_toEntity(response));
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<CartSummary>(failure.message, cause: failure);
    }
  }

  CartSummary _toEntity(CartResponseModel response) {
    final List<CartItem> items = response.items
        .map((model) {
          final CartItem? cached = _metadataByListingId[model.listingId];
          final CartItem item = CartItem(
            id: model.listingId,
            title: model.title.isNotEmpty ? model.title : cached?.title ?? '',
            subtitle: model.subtitle.isNotEmpty
                ? model.subtitle
                : cached?.subtitle ?? '',
            fileSize: model.fileSize.isNotEmpty
                ? model.fileSize
                : cached?.fileSize ?? '',
            imageUrl: model.coverImageUrl.isNotEmpty
                ? model.coverImageUrl
                : cached?.imageUrl ?? '',
            unitPrice: model.unitPrice,
            quantity: model.quantity,
          );
          _metadataByListingId[model.listingId] = item;
          return item;
        })
        .toList(growable: false);

    final double subtotal = items.fold<double>(
      0,
      (double value, CartItem item) => value + item.lineTotal,
    );

    return CartSummary(
      cartId: response.cartId,
      status: response.status,
      stripeCheckoutSessionId: response.stripeCheckoutSessionId,
      itemCount: response.itemCount,
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
