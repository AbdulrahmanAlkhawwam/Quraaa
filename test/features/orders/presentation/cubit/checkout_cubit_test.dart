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
      getOrder: GetOrderUseCase(ordersRepository),
      resumePendingOrderCheckout:
          ResumePendingOrderCheckoutUseCase(ordersRepository),
      profileRepository: profileRepository,
      verificationAttempts: 3,
      verificationDelay: (_) async {},
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

  test('polls the backend until the webhook marks the order paid', () async {
    int requestCount = 0;
    when(() => ordersRepository.getOrder('order-1')).thenAnswer((_) async {
      requestCount++;
      return Success<AccountOrder>(
        _orderWithPaymentStatus(requestCount == 1 ? 0 : 1),
      );
    });

    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?session_id=session-1',
      ),
    );

    expect(cubit.state, isA<CheckoutPaid>());
    verify(() => ordersRepository.getOrder('order-1')).called(2);
  });

  test('keeps the order pending when webhook confirmation is delayed',
      () async {
    when(
      () => ordersRepository.getOrder('order-1'),
    ).thenAnswer(
      (_) async => Success<AccountOrder>(_orderWithPaymentStatus(0)),
    );

    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?session_id=session-1',
      ),
    );

    expect(cubit.state, isA<CheckoutPaymentPending>());
    verify(() => ordersRepository.getOrder('order-1')).called(3);
  });

  test('does not query the order for a cancelled checkout', () async {
    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse('quraaa://checkout/cancel'),
    );

    expect(cubit.state, isA<CheckoutCancelled>());
    verifyNever(() => ordersRepository.getOrder(any()));
  });

  test('rejects a callback from a different Stripe session', () async {
    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?session_id=another-session',
      ),
    );

    expect(cubit.state, isA<CheckoutInvalidReturn>());
    verifyNever(() => ordersRepository.getOrder(any()));
  });
}

const OrderCheckout _checkout = OrderCheckout(
  orderId: 'order-1',
  orderNumber: 'Q-100',
  paymentAttemptId: 'attempt-1',
  checkoutSessionId: 'session-1',
  checkoutUrl: 'https://checkout.stripe.com/session-1',
  expiresAt: null,
);

AccountOrder _orderWithPaymentStatus(int paymentStatus) {
  return AccountOrder(
    orderId: 'order-1',
    orderNumber: 'Q-100',
    status: 0,
    paymentStatus: paymentStatus,
    currency: 'USD',
    totalAmount: 10,
    creationTime: null,
    items: const <AccountOrderItem>[],
  );
}
