import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/cart_response_model.dart';

abstract class CartRemoteDataSource {
  Future<CartResponseModel> getCart();

  Future<CartResponseModel> clearCart();

  Future<CartResponseModel> addItem({
    required String listingId,
    required int quantity,
  });
  Future<CartResponseModel> updateQuantity({
    required String listingId,
    required int quantity,
  });
  Future<CartResponseModel> removeItem(String listingId);
  Future<CartResponseModel> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  const CartRemoteDataSourceImpl(this._httpHelper);

  final HttpHelper _httpHelper;

  @override
  Future<CartResponseModel> getCart() =>
      _request(() => _httpHelper.get(ApiEndpoints.cart));

  @override
  Future<CartResponseModel> clearCart() =>
      _request(() => _httpHelper.delete(ApiEndpoints.cart));

  @override
  Future<CartResponseModel> addItem({
    required String listingId,
    required int quantity,
  }) {
    return _request(
      () => _httpHelper.post(
        ApiEndpoints.cartItems,
        data: <String, Object?>{'listingId': listingId, 'quantity': quantity},
      ),
    );
  }

  @override
  Future<CartResponseModel> updateQuantity({
    required String listingId,
    required int quantity,
  }) {
    return _request(
      () => _httpHelper.put(
        ApiEndpoints.cartItem(listingId),
        data: <String, Object?>{'quantity': quantity},
      ),
    );
  }

  @override
  Future<CartResponseModel> removeItem(String listingId) {
    return _request(() => _httpHelper.delete(ApiEndpoints.cartItem(listingId)));
  }

  Future<CartResponseModel> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final Response<dynamic> response = await request();
      final Object? data = response.data;
      if (data is Map) {
        return CartResponseModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw const UnknownException(message: 'Invalid cart response.');
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
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => const NetworkException(),
      _ => UnknownException(message: fallbackMessage),
    };
  }
}
