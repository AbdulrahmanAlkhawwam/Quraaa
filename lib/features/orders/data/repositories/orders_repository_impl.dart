import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/account_order.dart';
import '../../domain/entities/checkout_confirmation.dart';
import '../../domain/entities/order_checkout.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../../domain/repositories/orders_repository.dart';
import '../data_sources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._remoteDataSource);

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  FutureEither<AccountOrder> getOrder(String orderId) =>
      _guard(() => _remoteDataSource.getOrder(orderId));

  @override
  FutureEither<AccountOrder> updateShippingLocation({
    required String orderId,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) {
    return _guard(
      () => _remoteDataSource.updateShippingLocation(
        orderId: orderId,
        shippingLocationId: shippingLocationId,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  FutureEither<Unit> cancelOrder(String orderId, {String? reason}) =>
      _guardUnit(() => _remoteDataSource.cancelOrder(orderId, reason: reason));

  @override
  FutureEither<List<AccountOrder>> getMyOrders({int pageNumber = 1}) =>
      _guard(() => _remoteDataSource.getMyOrders(pageNumber: pageNumber));

  @override
  FutureEither<List<AccountOrder>> getSellHistory({int pageNumber = 1}) =>
      _guard(() => _remoteDataSource.getSellHistory(pageNumber: pageNumber));

  @override
  FutureEither<List<AccountOrder>> getSellerOrders({
    int pageNumber = 1,
    int? fulfillmentStatus,
  }) {
    return _guard(
      () => _remoteDataSource.getSellerOrders(
        pageNumber: pageNumber,
        fulfillmentStatus: fulfillmentStatus,
      ),
    );
  }

  @override
  FutureEither<Unit> markSellerItemProcessing(
    String orderId,
    String orderItemId,
  ) {
    return _guardUnit(
      () => _remoteDataSource.markSellerItemProcessing(orderId, orderItemId),
    );
  }

  @override
  FutureEither<Unit> markSellerItemFulfilled(
    String orderId,
    String orderItemId,
  ) {
    return _guardUnit(
      () => _remoteDataSource.markSellerItemFulfilled(orderId, orderItemId),
    );
  }

  @override
  FutureEither<OrderCheckoutContext> getCheckoutContext() =>
      _guard(_remoteDataSource.getCheckoutContext);

  @override
  FutureEither<OrderCheckout> createOrder({
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) {
    return _guard(
      () async => (await _remoteDataSource.createOrder(
        shippingLocationId: shippingLocationId,
        latitude: latitude,
        longitude: longitude,
      )).toEntity(),
    );
  }

  @override
  FutureEither<OrderCheckout> resumePendingOrderCheckout() {
    return _guard(
      () async =>
          (await _remoteDataSource.resumePendingOrderCheckout()).toEntity(),
    );
  }

  @override
  FutureEither<CheckoutConfirmation> confirmCheckout(String sessionId) {
    return _guard(
      () async => (await _remoteDataSource.confirmCheckout(
        sessionId,
      )).toEntity(),
    );
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  FutureEither<Unit> _guardUnit(Future<void> Function() request) =>
      _guard(() async {
        await request();
        return unit;
      });
}
