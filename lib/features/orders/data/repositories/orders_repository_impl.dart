import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_order.dart';
import '../../domain/entities/order_checkout.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_checkout_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._remoteDataSource);

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AccountOrder>> getOrder(String orderId) async {
    try {
      return Success<AccountOrder>(await _remoteDataSource.getOrder(orderId));
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<AccountOrder>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<AccountOrder>> updateShippingLocation({
    required String orderId,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      return Success<AccountOrder>(
        await _remoteDataSource.updateShippingLocation(
          orderId: orderId,
          shippingLocationId: shippingLocationId,
          latitude: latitude,
          longitude: longitude,
        ),
      );
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<AccountOrder>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<void>> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _remoteDataSource.cancelOrder(orderId, reason: reason);
      return const Success<void>(null);
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<void>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<List<AccountOrder>>> getMyOrders({int pageNumber = 1}) async {
    try {
      return Success<List<AccountOrder>>(
        await _remoteDataSource.getMyOrders(pageNumber: pageNumber),
      );
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<List<AccountOrder>>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<List<AccountOrder>>> getSellHistory({
    int pageNumber = 1,
  }) async {
    try {
      return Success<List<AccountOrder>>(
        await _remoteDataSource.getSellHistory(pageNumber: pageNumber),
      );
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<List<AccountOrder>>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<List<AccountOrder>>> getSellerOrders({
    int pageNumber = 1,
    int? fulfillmentStatus,
  }) async {
    try {
      return Success<List<AccountOrder>>(
        await _remoteDataSource.getSellerOrders(
          pageNumber: pageNumber,
          fulfillmentStatus: fulfillmentStatus,
        ),
      );
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<List<AccountOrder>>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<void>> markSellerItemProcessing(
    String orderId,
    String orderItemId,
  ) async {
    try {
      await _remoteDataSource.markSellerItemProcessing(orderId, orderItemId);
      return const Success<void>(null);
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<void>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<void>> markSellerItemFulfilled(
    String orderId,
    String orderItemId,
  ) async {
    try {
      await _remoteDataSource.markSellerItemFulfilled(orderId, orderItemId);
      return const Success<void>(null);
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<void>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<OrderCheckoutContext>> getCheckoutContext() async {
    try {
      return Success<OrderCheckoutContext>(
        await _remoteDataSource.getCheckoutContext(),
      );
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<OrderCheckoutContext>(
        failure.message,
        cause: failure,
      );
    }
  }

  @override
  Future<Result<OrderCheckout>> createOrder({
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final OrderCheckoutModel model = await _remoteDataSource.createOrder(
        shippingLocationId: shippingLocationId,
        latitude: latitude,
        longitude: longitude,
      );
      return Success<OrderCheckout>(model.toEntity());
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<OrderCheckout>(failure.message, cause: failure);
    }
  }

  @override
  Future<Result<OrderCheckout>> resumePendingOrderCheckout() async {
    try {
      final OrderCheckoutModel model =
          await _remoteDataSource.resumePendingOrderCheckout();
      return Success<OrderCheckout>(model.toEntity());
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<OrderCheckout>(failure.message, cause: failure);
    }
  }
}
