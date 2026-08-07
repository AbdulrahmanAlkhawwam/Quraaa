import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/order_checkout_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrderCheckoutModel> createOrder({
    required String successUrl,
    required String cancelUrl,
    double? latitude,
    double? longitude,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<OrderCheckoutModel> createOrder({
    required String successUrl,
    required String cancelUrl,
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
          if (hasLocation)
            'shippingLocation': <String, Object?>{
              'latitude': latitude,
              'longitude': longitude,
            },
        },
      );
      final Object? data = response.data;
      if (data is Map) {
        final OrderCheckoutModel model = OrderCheckoutModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (model.orderId.isNotEmpty && model.checkoutUrl.isNotEmpty) {
          return model;
        }
      }
      throw const UnknownException(message: 'Invalid checkout response.');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
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
    return UnknownException(
      message: error.message ?? 'Unable to create order.',
    );
  }
}
