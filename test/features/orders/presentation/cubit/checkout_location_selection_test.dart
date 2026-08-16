import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/orders/orders.dart';
import 'package:quraaa/features/profile/profile.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  test('checkout uses the location selected in the checkout sheet', () async {
    final _MockOrdersRepository ordersRepository = _MockOrdersRepository();
    final _MockProfileRepository profileRepository = _MockProfileRepository();
    final CheckoutCubit cubit = CheckoutCubit(
      createOrder: CreateOrderUseCase(ordersRepository),
      getCheckoutContext: GetOrderCheckoutContextUseCase(ordersRepository),
      resumePendingOrderCheckout:
          ResumePendingOrderCheckoutUseCase(ordersRepository),
      profileRepository: profileRepository,
    );
    addTearDown(cubit.close);

    const OrderCheckoutContext checkoutContext = OrderCheckoutContext(
      requiresShippingLocation: true,
      selectedShippingLocationId: 'home',
      locations: <OrderCheckoutLocation>[
        OrderCheckoutLocation(
          id: 'home',
          latitude: 33.5,
          longitude: 36.3,
          isDefault: true,
        ),
        OrderCheckoutLocation(
          id: 'office',
          latitude: 33.51,
          longitude: 36.31,
          isDefault: false,
        ),
      ],
    );
    const OrderCheckout checkout = OrderCheckout(
      orderId: 'order-1',
      orderNumber: 'Q-100',
      paymentAttemptId: 'attempt-1',
      checkoutSessionId: 'session-1',
      checkoutUrl: 'https://checkout.stripe.com/session-1',
      expiresAt: null,
    );
    when(
      ordersRepository.getCheckoutContext,
    ).thenAnswer(
      (_) async => const Success<OrderCheckoutContext>(checkoutContext),
    );
    when(
      () => ordersRepository.createOrder(
        successUrl: any(named: 'successUrl'),
        cancelUrl: any(named: 'cancelUrl'),
        shippingLocationId: 'office',
      ),
    ).thenAnswer((_) async => const Success<OrderCheckout>(checkout));

    await cubit.startCheckout(shippingLocationId: 'office');

    expect(cubit.state, isA<CheckoutReady>());
    verify(
      () => ordersRepository.createOrder(
        successUrl: any(named: 'successUrl'),
        cancelUrl: any(named: 'cancelUrl'),
        shippingLocationId: 'office',
      ),
    ).called(1);
    verifyNever(profileRepository.getCachedProfile);
  });
}
