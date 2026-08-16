import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/orders/orders.dart';
import 'package:quraaa/features/profile/profile.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockOrdersRepository ordersRepository;
  late _MockProfileRepository profileRepository;
  late CheckoutCubit cubit;

  setUp(() {
    ordersRepository = _MockOrdersRepository();
    profileRepository = _MockProfileRepository();
    cubit = CheckoutCubit(
      createOrder: CreateOrderUseCase(ordersRepository),
      getCheckoutContext: GetOrderCheckoutContextUseCase(ordersRepository),
      resumePendingOrderCheckout:
          ResumePendingOrderCheckoutUseCase(ordersRepository),
      profileRepository: profileRepository,
    );
  });

  tearDown(() => cubit.close());

  test('uses the backend-selected shipping location for checkout', () async {
    const OrderCheckoutContext context = OrderCheckoutContext(
      requiresShippingLocation: true,
      selectedShippingLocationId: 'location-2',
      locations: <OrderCheckoutLocation>[
        OrderCheckoutLocation(
          id: 'location-2',
          latitude: 33.5,
          longitude: 36.3,
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
      () => ordersRepository.getCheckoutContext(),
    ).thenAnswer((_) async => const Success<OrderCheckoutContext>(context));
    when(
      () => ordersRepository.createOrder(
        successUrl: any(named: 'successUrl'),
        cancelUrl: any(named: 'cancelUrl'),
        shippingLocationId: 'location-2',
      ),
    ).thenAnswer((_) async => const Success<OrderCheckout>(checkout));

    await cubit.startCheckout();

    expect(cubit.state, isA<CheckoutReady>());
    verifyNever(() => profileRepository.getCachedProfile());
    verify(
      () => ordersRepository.createOrder(
        successUrl: any(named: 'successUrl'),
        cancelUrl: any(named: 'cancelUrl'),
        shippingLocationId: 'location-2',
      ),
    ).called(1);
  });

  test('resumes a pending order without creating another order', () async {
    const OrderCheckout checkout = OrderCheckout(
      orderId: 'order-1',
      orderNumber: 'Q-100',
      paymentAttemptId: 'attempt-2',
      checkoutSessionId: 'session-2',
      checkoutUrl: 'https://checkout.stripe.com/session-2',
      expiresAt: null,
    );
    when(
      () => ordersRepository.resumePendingOrderCheckout(
        successUrl: any(named: 'successUrl'),
        cancelUrl: any(named: 'cancelUrl'),
      ),
    ).thenAnswer((_) async => const Success<OrderCheckout>(checkout));

    await cubit.resumePendingCheckout();

    expect(cubit.state, isA<CheckoutReady>());
    verify(
      () => ordersRepository.resumePendingOrderCheckout(
        successUrl: any(named: 'successUrl'),
        cancelUrl: any(named: 'cancelUrl'),
      ),
    ).called(1);
    verifyNever(ordersRepository.getCheckoutContext);
  });
}
