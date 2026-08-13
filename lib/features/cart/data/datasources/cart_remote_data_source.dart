import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/error_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_helper.dart';
import '../models/cart_response_model.dart';

abstract interface class CartRemoteDataSource {
  Future<CartResponseModel> getCart();
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
  Future<CartResponseModel> getCart() => _request(
    () => _httpHelper.get(ApiEndpoints.cartMe),
    'Unable to load your cart.',
  );

  @override
  Future<CartResponseModel> addItem({
    required String listingId,
    required int quantity,
  }) => _request(
    () => _httpHelper.post(
      ApiEndpoints.cartItems,
      data: <String, Object?>{'listingId': listingId, 'quantity': quantity},
    ),
    'Unable to add this item to your cart.',
  );

  @override
  Future<CartResponseModel> updateQuantity({
    required String listingId,
    required int quantity,
  }) => _request(
    () => _httpHelper.put(
      ApiEndpoints.cartItem(listingId),
      data: <String, Object?>{'quantity': quantity},
    ),
    'Unable to update the item quantity.',
  );

  @override
  Future<CartResponseModel> removeItem(String listingId) => _request(
    () => _httpHelper.delete(ApiEndpoints.cartItem(listingId)),
    'Unable to remove this item from your cart.',
  );

  @override
  Future<CartResponseModel> clearCart() => _request(
    () => _httpHelper.delete(ApiEndpoints.cartMe),
    'Unable to clear your cart.',
  );

  Future<CartResponseModel> _request(
    Future<Response<dynamic>> Function() request,
    String fallbackMessage,
  ) async {
    try {
      final Response<dynamic> response = await request();
      if (response.data is Map) {
        return CartResponseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw const UnknownException(message: 'Invalid cart response.');
    } on DioException catch (error) {
      throw _mapDioException(error, fallbackMessage);
    }
  }

  AppException _mapDioException(DioException error, String fallbackMessage) {
    if (error.error case final AppException exception) return exception;
    final dynamic payload = error.response?.data;
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
