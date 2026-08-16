import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/cart/data/datasources/cart_remote_data_source.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  test('sends listingId when adding an item to the cart', () async {
    const String listingId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
    final _MockHttpHelper httpHelper = _MockHttpHelper();
    final CartRemoteDataSource dataSource =
        CartRemoteDataSourceImpl(httpHelper);

    when(
      () => httpHelper.post(
        ApiEndpoints.cartItems,
        data: <String, Object?>{'listingId': listingId, 'quantity': 1},
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'cartId': 'cart-id',
          'status': 'Active',
          'items': <dynamic>[],
          'totalAmount': 0,
          'itemCount': 0,
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await dataSource.addItem(listingId: listingId, quantity: 1);

    verify(
      () => httpHelper.post(
        ApiEndpoints.cartItems,
        data: <String, Object?>{'listingId': listingId, 'quantity': 1},
      ),
    ).called(1);
  });
}
