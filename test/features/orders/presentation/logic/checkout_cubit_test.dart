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
      confirmCheckout: ConfirmCheckoutUseCase(ordersRepository),
      resumePendingOrderCheckout:
          ResumePendingOrderCheckoutUseCase(ordersRepository),
      profileRepository: profileRepository,
      verificationAttempts: 5,
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
        shippingLocationId: 'location-2',
      ),
    ).thenAnswer((_) async => const Success<OrderCheckout>(checkout));

    await cubit.startCheckout();

    expect(cubit.state, isA<CheckoutReady>());
    verifyNever(() => profileRepository.getCachedProfile());
    verify(
      () => ordersRepository.createOrder(
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
      () => ordersRepository.resumePendingOrderCheckout(),
    ).thenAnswer((_) async => const Success<OrderCheckout>(checkout));

    await cubit.resumePendingCheckout();

    expect(cubit.state, isA<CheckoutReady>());
    verify(
      () => ordersRepository.resumePendingOrderCheckout(),
    ).called(1);
    verifyNever(ordersRepository.getCheckoutContext);
  });

  test('confirms the stored session without comparing callback sessionId',
      () async {
    int requestCount = 0;
    when(() => ordersRepository.confirmCheckout('session-1'))
        .thenAnswer((_) async {
      requestCount++;
      return Success<CheckoutConfirmation>(
        _confirmation(
          paid: requestCount > 1,
          pending: requestCount == 1,
        ),
      );
    });

    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?orderId=order-1&sessionId=another-session',
      ),
    );

    expect(cubit.state, isA<CheckoutPaid>());
    expect(
      (cubit.state as CheckoutPaid).confirmation.orderNumber,
      'ORD-100',
    );
    verify(() => ordersRepository.confirmCheckout('session-1')).called(2);
  });

  test('fails after five pending backend confirmations', () async {
    when(
      () => ordersRepository.confirmCheckout('session-1'),
    ).thenAnswer(
      (_) async => Success<CheckoutConfirmation>(
        _confirmation(paid: false, pending: true),
      ),
    );

    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?orderId=order-1',
      ),
    );

    expect(cubit.state, isA<CheckoutPaymentFailed>());
    verify(() => ordersRepository.confirmCheckout('session-1')).called(5);
  });

  test('stops polling when backend reports a terminal payment failure',
      () async {
    when(
      () => ordersRepository.confirmCheckout('session-1'),
    ).thenAnswer(
      (_) async => Success<CheckoutConfirmation>(
        _confirmation(paid: false, pending: false),
      ),
    );

    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?orderId=order-1&sessionId=session-1',
      ),
    );

    expect(cubit.state, isA<CheckoutPaymentFailed>());
    verify(() => ordersRepository.confirmCheckout('session-1')).called(1);
  });

  test('does not confirm a cancelled checkout', () async {
    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse('quraaa://checkout/cancel?orderId=order-1'),
    );

    expect(cubit.state, isA<CheckoutCancelled>());
    verifyNever(() => ordersRepository.confirmCheckout(any()));
  });

  test('rejects a callback for a different order', () async {
    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?orderId=order-2',
      ),
    );

    expect(cubit.state, isA<CheckoutInvalidReturn>());
    verifyNever(() => ordersRepository.confirmCheckout(any()));
  });

  test('rejects a confirmation that belongs to another order', () async {
    when(
      () => ordersRepository.confirmCheckout('session-1'),
    ).thenAnswer(
      (_) async => Success<CheckoutConfirmation>(
        _confirmation(paid: true, pending: false, orderId: 'order-2'),
      ),
    );

    await cubit.handleCheckoutReturn(
      checkout: _checkout,
      callbackUri: Uri.parse(
        'quraaa://checkout/success?orderId=order-1',
      ),
    );

    expect(cubit.state, isA<CheckoutFailure>());
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

CheckoutConfirmation _confirmation({
  required bool paid,
  required bool pending,
  String orderId = 'order-1',
}) {
  return CheckoutConfirmation(
    paid: paid,
    pending: pending,
    orderId: orderId,
    orderNumber: 'ORD-100',
    orderStatus: paid ? 'Processing' : 'Pending',
    paymentStatus: paid ? 'Paid' : 'Pending',
  );
}
