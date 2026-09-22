import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/order_checkout_context_model.dart';
import '../models/checkout_confirmation_model.dart';
import '../models/order_checkout_model.dart';
import '../models/account_order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<AccountOrderModel> getOrder(String orderId);

  Future<OrderCheckoutContextModel> getCheckoutContext();

  Future<OrderCheckoutModel> createOrder({
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });

  Future<OrderCheckoutModel> resumePendingOrderCheckout();
  Future<CheckoutConfirmationModel> confirmCheckout(String sessionId);

  Future<List<AccountOrderModel>> getMyOrders({int pageNumber = 1});

  Future<AccountOrderModel> updateShippingLocation({
    required String orderId,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  });
  Future<void> cancelOrder(String orderId, {String? reason});

  Future<List<AccountOrderModel>> getSellHistory({int pageNumber = 1});

  Future<List<AccountOrderModel>> getSellerOrders({
    int pageNumber = 1,
    int? fulfillmentStatus,
  });

  Future<void> markSellerItemProcessing(String orderId, String orderItemId);
  Future<void> markSellerItemFulfilled(String orderId, String orderItemId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<AccountOrderModel> getOrder(String orderId) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.order(orderId),
      );
      final Object? responseData = response.data;
      if (responseData is Map) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          responseData,
        );
        final Object? nestedOrder = data['order'];
        return AccountOrderModel.fromJson(
          nestedOrder is Map ? Map<String, dynamic>.from(nestedOrder) : data,
        );
      }
      throw const UnknownException(message: 'Invalid order response.');
    } on DioException catch (error) {
      throw _mapDioException(error, fallback: 'Unable to load the order.');
    }
  }

  @override
  Future<AccountOrderModel> updateShippingLocation({
    required String orderId,
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.put(
        ApiEndpoints.orderShippingLocation(orderId),
        data: <String, Object?>{
          if (shippingLocationId?.trim().isNotEmpty == true)
            'shippingLocationId': shippingLocationId!.trim(),
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
      if (response.data is Map) {
        return AccountOrderModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const UnknownException(message: 'Invalid updated order response.');
    } on DioException catch (error) {
      throw _mapDioException(
        error,
        fallback: 'Unable to update the shipping location.',
      );
    }
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _httpHelper.post(
        ApiEndpoints.orderCancel(orderId),
        data: <String, Object?>{
          if (reason?.trim().isNotEmpty == true) 'reason': reason!.trim(),
        },
      );
    } on DioException catch (error) {
      throw _mapDioException(error, fallback: 'Unable to cancel order.');
    }
  }

  @override
  Future<void> markSellerItemProcessing(
    String orderId,
    String orderItemId,
  ) async {
    await _httpHelper.post(
      ApiEndpoints.sellerOrderProcessing(orderId, orderItemId),
    );
  }

  @override
  Future<void> markSellerItemFulfilled(
    String orderId,
    String orderItemId,
  ) async {
    await _httpHelper.post(
      ApiEndpoints.sellerOrderFulfilled(orderId, orderItemId),
    );
  }

  @override
  Future<List<AccountOrderModel>> getMyOrders({int pageNumber = 1}) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.myOrders,
        queryParameters: <String, dynamic>{
          'PageNumber': pageNumber,
          'PageSize': 20,
        },
      );
      final List<Map<String, dynamic>> summaries = _items(response.data);
      return Future.wait(
        summaries.map((Map<String, dynamic> summary) async {
          final String id = summary['orderId']?.toString() ?? '';
          if (id.isEmpty) return AccountOrderModel.fromJson(summary);
          try {
            final Response<dynamic> details = await _httpHelper.get(
              ApiEndpoints.order(id),
            );
            if (details.data is Map) {
              return AccountOrderModel.fromJson(
                Map<String, dynamic>.from(details.data as Map),
              );
            }
          } on DioException {
            // Keep the summary visible if one details request fails.
          }
          return AccountOrderModel.fromJson(summary);
        }),
      );
    } on DioException catch (error) {
      throw _mapDioException(error, fallback: 'Unable to load orders.');
    }
  }

  @override
  Future<List<AccountOrderModel>> getSellHistory({int pageNumber = 1}) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.sellHistory,
        queryParameters: <String, dynamic>{
          'PageNumber': pageNumber,
          'PageSize': 50,
        },
      );
      return _items(response.data)
          .map(AccountOrderModel.fromSellHistory)
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapDioException(error, fallback: 'Unable to load sales history.');
    }
  }

  @override
  Future<List<AccountOrderModel>> getSellerOrders({
    int pageNumber = 1,
    int? fulfillmentStatus,
  }) async {
    try {
      final Response<dynamic> response = await _httpHelper.get(
        ApiEndpoints.sellerOrders,
        queryParameters: <String, dynamic>{
          'PageNumber': pageNumber,
          'PageSize': 50,
          if (fulfillmentStatus != null) 'FulfillmentStatus': fulfillmentStatus,
        },
      );
      final Map<String, AccountOrderModel> grouped =
          <String, AccountOrderModel>{};
      for (final Map<String, dynamic> item in _items(response.data)) {
        final String id = item['orderId']?.toString() ?? '';
        if (id.isEmpty) continue;
        grouped[id] = grouped[id]?.mergeSellerItem(item) ??
            AccountOrderModel.fromSellerItem(item);
      }
      return grouped.values.toList(growable: false);
    } on DioException catch (error) {
      throw _mapDioException(error, fallback: 'Unable to load sales.');
    }
  }

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
    String? shippingLocationId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final bool hasLocation = latitude != null && longitude != null;
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.orders,
        data: <String, Object?>{
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
  Future<OrderCheckoutModel> resumePendingOrderCheckout() async {
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
      );
      return _parseCheckout(response.data);
    } on DioException catch (error) {
      throw _mapDioException(
        error,
        fallback: 'Unable to resume the pending payment.',
      );
    }
  }

  @override
  Future<CheckoutConfirmationModel> confirmCheckout(String sessionId) async {
    try {
      final Response<dynamic> response = await _httpHelper.post(
        ApiEndpoints.ordersCheckoutConfirm,
        data: <String, Object?>{'sessionId': sessionId.trim()},
      );
      final Object? data = response.data;
      if (data is Map) {
        return CheckoutConfirmationModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw const UnknownException(
        message: 'Invalid checkout confirmation response.',
      );
    } on DioException catch (error) {
      throw _mapDioException(
        error,
        fallback: 'Unable to confirm the checkout.',
      );
    } on FormatException catch (error) {
      throw UnknownException(message: error.message);
    }
  }

  OrderCheckoutModel _parseCheckout(Object? payload) {
    if (payload is Map) {
      final OrderCheckoutModel model = OrderCheckoutModel.fromJson(
        Map<String, dynamic>.from(payload),
      );
      if (model.orderId.isNotEmpty &&
          model.checkoutSessionId.isNotEmpty &&
          model.checkoutUrl.isNotEmpty) {
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

  List<Map<String, dynamic>> _items(Object? payload) {
    final Object? raw = payload is Map ? payload['items'] : payload;
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
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
