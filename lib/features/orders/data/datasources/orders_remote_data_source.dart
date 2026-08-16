import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/order_checkout_context_model.dart';
import '../models/order_checkout_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrderCheckoutContextModel> getCheckoutContext();

  Future<OrderCheckoutModel> createOrder({
    required String successUrl,
    required String cancelUrl,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });

  Future<OrderCheckoutModel> resumePendingOrderCheckout({
    required String successUrl,
    required String cancelUrl,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<OrderCheckoutContextModel> getCheckoutContext() async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.ordersCheckoutContext,
      );
      final Object? data = response.data;
      if (data is Map) {
        return OrderCheckoutContextModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw const UnknownException(message: 'Invalid checkout context.');
    } on DioException catch (error) {
      throw _mapDioException(error, fallback: 'Unable to load checkout.');
    } on FormatException catch (error) {
      throw UnknownException(message: error.message);
    }
  }

  @override
  Future<OrderCheckoutModel> createOrder({
    required String successUrl,
    required String cancelUrl,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final bool hasLocation = latitude != null && longitude != null;
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.orders,
        data: <String, Object?>{
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
          if (shippingLocationId?.trim().isNotEmpty == true)
            'shippingLocationId': shippingLocationId!.trim()
          else if (hasLocation)
            'shippingLocation': <String, Object?>{
              'latitude': latitude,
              'longitude': longitude,
            },
        },
      );
      return _parseCheckout(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error, fallback: 'Unable to create order.');
    }
  }

  @override
  Future<OrderCheckoutModel> resumePendingOrderCheckout({
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final Response<dynamic> ordersResponse = await _httpHelper.get(
        ApiEndpoints.ordersMine,
        queryParameters: <String, dynamic>{
          'PageNumber': 1,
          'PageSize': 20,
        },
      );
      final String? pendingOrderId = _pendingOrderId(ordersResponse.data);
      if (pendingOrderId == null) {
        throw const NotFoundException(
          message: 'No pending order is available to resume.',
        );
      }

      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.orderCheckoutSession(pendingOrderId),
        data: <String, Object?>{
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        },
      );
      return _parseCheckout(response.data);
    } on DioException catch (error) {
      throw _mapDioException(
        error,
        fallback: 'Unable to resume the pending payment.',
      );
    }
  }

  OrderCheckoutModel _parseCheckout(Object? payload) {
    if (payload is Map) {
      final OrderCheckoutModel model = OrderCheckoutModel.fromJson(
        Map<String, dynamic>.from(payload),
      );
      if (model.orderId.isNotEmpty && model.checkoutUrl.isNotEmpty) {
        return model;
      }
    }
    throw const UnknownException(message: 'Invalid checkout response.');
  }

  String? _pendingOrderId(Object? payload) {
    if (payload is! Map) return null;
    final Object? rawItems = payload['items'];
    if (rawItems is! List) return null;
    for (final Object? rawItem in rawItems) {
      if (rawItem is! Map) continue;
      final Map<String, dynamic> item = Map<String, dynamic>.from(rawItem);
      final String status = item['status']?.toString().toLowerCase() ?? '';
      final String paymentStatus =
          item['paymentStatus']?.toString().toLowerCase() ?? '';
      final String orderId = item['orderId']?.toString().trim() ?? '';
      if (status == 'pending' &&
          paymentStatus == 'pending' &&
          orderId.isNotEmpty) {
        return orderId;
      }
    }
    return null;
  }

  AppException _mapDioException(
    DioException error, {
    required String fallback,
  }) {
    final Object? underlying = error.error;
    if (underlying is AppException) return underlying;
    final Object? payload = error.response?.data;
    if (payload is Map) {
      return ErrorMapper.mapResponseToException(
        ErrorResponseModel.fromJson(
          Map<String, dynamic>.from(payload),
          statusCode: error.response?.statusCode,
        ),
      );
    }
    return UnknownException(message: error.message ?? fallback);
  }
}
