import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/orders/data/datasources/orders_remote_data_source.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  late _MockHttpHelper httpHelper;
  late OrdersRemoteDataSource dataSource;

  setUp(() {
    httpHelper = _MockHttpHelper();
    dataSource = OrdersRemoteDataSourceImpl(httpHelper);
  });

  test('loads and parses the checkout shipping context', () async {
    when(() => httpHelper.get(ApiEndpoints.ordersCheckoutContext)).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'requiresShippingLocation': true,
          'selectedShippingLocationId': 'location-2',
          'locations': <Object?>[
            <String, dynamic>{
              'id': 'location-1',
              'name': 'Home',
              'latitude': 33.5,
              'longitude': 36.3,
              'isDefault': true,
            },
            <String, dynamic>{
              'id': 'location-2',
              'name': 'Office',
              'latitude': 33.51,
              'longitude': 36.31,
              'isDefault': false,
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final context = await dataSource.getCheckoutContext();

    expect(context.requiresShippingLocation, isTrue);
    expect(context.locations, hasLength(2));
    expect(context.preferredLocation?.id, 'location-2');
    verify(() => httpHelper.get(ApiEndpoints.ordersCheckoutContext)).called(1);
  });

  test('creates an order with a saved shipping location id', () async {
    when(
      () => httpHelper.post(
        ApiEndpoints.orders,
        data: <String, Object?>{
          'successUrl': 'https://example.com/success',
          'cancelUrl': 'https://example.com/cancel',
          'shippingLocationId': 'location-2',
        },
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'order': <String, dynamic>{
            'orderId': 'order-1',
            'orderNumber': 'Q-100',
          },
          'paymentAttemptId': 'attempt-1',
          'checkoutSessionId': 'session-1',
          'checkoutUrl': 'https://checkout.stripe.com/session-1',
          'expiresAt': '2026-08-16T12:00:00Z',
        },
        statusCode: 201,
        requestOptions: RequestOptions(),
      ),
    );

    final checkout = await dataSource.createOrder(
      successUrl: 'https://example.com/success',
      cancelUrl: 'https://example.com/cancel',
      shippingLocationId: 'location-2',
      latitude: 33.5,
      longitude: 36.3,
    );

    expect(checkout.orderId, 'order-1');
    verify(
      () => httpHelper.post(
        ApiEndpoints.orders,
        data: <String, Object?>{
          'successUrl': 'https://example.com/success',
          'cancelUrl': 'https://example.com/cancel',
          'shippingLocationId': 'location-2',
        },
      ),
    ).called(1);
  });

  test('updates an order shipping location with the saved location id',
      () async {
    when(
      () => httpHelper.put(
        ApiEndpoints.orderShippingLocation('order-1'),
        data: <String, Object?>{'shippingLocationId': 'location-2'},
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'orderId': 'order-1',
          'orderNumber': 'Q-100',
          'status': 'Pending',
          'paymentStatus': 'Paid',
          'currency': 'usd',
          'totalAmount': 10,
          'items': <Object?>[],
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final order = await dataSource.updateShippingLocation(
      orderId: 'order-1',
      shippingLocationId: 'location-2',
    );

    expect(order.orderId, 'order-1');
    verify(
      () => httpHelper.put(
        ApiEndpoints.orderShippingLocation('order-1'),
        data: <String, Object?>{'shippingLocationId': 'location-2'},
      ),
    ).called(1);
  });
  test('resumes the pending order instead of creating a duplicate', () async {
    when(
      () => httpHelper.get(
        ApiEndpoints.ordersMine,
        queryParameters: <String, dynamic>{
          'PageNumber': 1,
          'PageSize': 20,
        },
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'items': <Object?>[
            <String, dynamic>{
              'orderId': 'order-1',
              'status': 'Pending',
              'paymentStatus': 'Pending',
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );
    when(
      () => httpHelper.post(
        ApiEndpoints.orderCheckoutSession('order-1'),
        data: <String, Object?>{
          'successUrl': 'https://example.com/success',
          'cancelUrl': 'https://example.com/cancel',
        },
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'order': <String, dynamic>{
            'orderId': 'order-1',
            'orderNumber': 'Q-100',
          },
          'paymentAttemptId': 'attempt-2',
          'checkoutSessionId': 'session-2',
          'checkoutUrl': 'https://checkout.stripe.com/session-2',
          'expiresAt': '2026-08-16T12:00:00Z',
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final checkout = await dataSource.resumePendingOrderCheckout(
      successUrl: 'https://example.com/success',
      cancelUrl: 'https://example.com/cancel',
    );

    expect(checkout.orderId, 'order-1');
    expect(checkout.checkoutSessionId, 'session-2');
    verify(
      () => httpHelper.post(
        ApiEndpoints.orderCheckoutSession('order-1'),
        data: <String, Object?>{
          'successUrl': 'https://example.com/success',
          'cancelUrl': 'https://example.com/cancel',
        },
      ),
    ).called(1);
    verifyNever(
      () => httpHelper.post(
        ApiEndpoints.orders,
        data: any(named: 'data'),
      ),
    );
  });
}
