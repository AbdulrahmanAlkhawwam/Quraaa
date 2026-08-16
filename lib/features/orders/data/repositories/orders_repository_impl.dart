import '../../../../core/architecture/result.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_checkout.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_checkout_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._remoteDataSource);

  final OrdersRemoteDataSource _remoteDataSource;

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
    required String successUrl,
    required String cancelUrl,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final OrderCheckoutModel model = await _remoteDataSource.createOrder(
        successUrl: successUrl,
        cancelUrl: cancelUrl,
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
  Future<Result<OrderCheckout>> resumePendingOrderCheckout({
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final OrderCheckoutModel model =
          await _remoteDataSource.resumePendingOrderCheckout(
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );
      return Success<OrderCheckout>(model.toEntity());
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<OrderCheckout>(failure.message, cause: failure);
    }
  }
}
