import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/env/env.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../profile/profile.dart';
import '../../domain/entities/account_order.dart';
import '../../domain/entities/order_checkout.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../../domain/use_cases/create_order_use_case.dart';
import '../../domain/use_cases/get_order_checkout_context_use_case.dart';
import '../../domain/use_cases/get_order_use_case.dart';
import '../../domain/use_cases/resume_pending_order_checkout_use_case.dart';

typedef CheckoutDelay = Future<void> Function(Duration duration);

Future<void> _defaultCheckoutDelay(Duration duration) =>
    Future<void>.delayed(duration);

sealed class CheckoutState {
  const CheckoutState();
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

final class CheckoutReady extends CheckoutState {
  const CheckoutReady(this.checkout);

  final OrderCheckout checkout;
}

final class CheckoutVerifying extends CheckoutState {
  const CheckoutVerifying();
}

final class CheckoutPaid extends CheckoutState {
  const CheckoutPaid(this.order);

  final AccountOrder order;
}

final class CheckoutCancelled extends CheckoutState {
  const CheckoutCancelled();
}

final class CheckoutPaymentPending extends CheckoutState {
  const CheckoutPaymentPending();
}

final class CheckoutPaymentFailed extends CheckoutState {
  const CheckoutPaymentFailed();
}

final class CheckoutInvalidReturn extends CheckoutState {
  const CheckoutInvalidReturn();
}

final class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.error);

  final Object error;
}

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required CreateOrderUseCase createOrder,
    required GetOrderCheckoutContextUseCase getCheckoutContext,
    required GetOrderUseCase getOrder,
    required ResumePendingOrderCheckoutUseCase resumePendingOrderCheckout,
    required ProfileRepository profileRepository,
    Duration verificationInterval = const Duration(seconds: 2),
    int verificationAttempts = 6,
    CheckoutDelay verificationDelay = _defaultCheckoutDelay,
  })  : assert(verificationAttempts > 0),
        _createOrder = createOrder,
        _getCheckoutContext = getCheckoutContext,
        _getOrder = getOrder,
        _resumePendingOrderCheckout = resumePendingOrderCheckout,
        _profileRepository = profileRepository,
        _verificationInterval = verificationInterval,
        _verificationAttempts = verificationAttempts,
        _verificationDelay = verificationDelay,
        super(const CheckoutInitial());

  final CreateOrderUseCase _createOrder;
  final GetOrderCheckoutContextUseCase _getCheckoutContext;
  final GetOrderUseCase _getOrder;
  final ResumePendingOrderCheckoutUseCase _resumePendingOrderCheckout;
  final ProfileRepository _profileRepository;
  final Duration _verificationInterval;
  final int _verificationAttempts;
  final CheckoutDelay _verificationDelay;

  Future<void> startCheckout({String? shippingLocationId}) async {
    if (state is CheckoutLoading) return;
    emit(const CheckoutLoading());

    final Result<OrderCheckoutContext> contextResult =
        await _getCheckoutContext(const NoParams());
    if (contextResult
        case ResultFailure<OrderCheckoutContext>(
          message: final message,
          cause: final cause,
        )) {
      emit(CheckoutFailure(cause ?? message));
      return;
    }
    final OrderCheckoutContext checkoutContext =
        (contextResult as Success<OrderCheckoutContext>).value;
    final OrderCheckoutLocation? preferredLocation =
        checkoutContext.preferredLocation;
    final String requestedLocationId = shippingLocationId?.trim() ?? '';
    final bool requestedLocationExists = checkoutContext.locations.any(
      (OrderCheckoutLocation location) => location.id == requestedLocationId,
    );
    final String? effectiveLocationId =
        requestedLocationId.isNotEmpty && requestedLocationExists
            ? requestedLocationId
            : preferredLocation?.id;

    Profile? profile;
    if (checkoutContext.requiresShippingLocation &&
        effectiveLocationId == null) {
      try {
        profile = await _profileRepository.getCachedProfile();
        profile ??= await _profileRepository.getMyProfile();
      } catch (_) {
        // The backend returns a validation error if a physical order still
        // has no usable shipping location.
      }
    }

    final ProfileLocation? location = profile?.location;
    final Result<OrderCheckout> result = await _createOrder(
      CreateOrderParams(
        shippingLocationId: effectiveLocationId ?? location?.id,
        latitude: location?.latitude,
        longitude: location?.longitude,
      ),
    );
    _emitCheckoutResult(result);
  }

  Future<void> resumePendingCheckout() async {
    if (state is CheckoutLoading) return;
    emit(const CheckoutLoading());
    final Result<OrderCheckout> result = await _resumePendingOrderCheckout(
      const NoParams(),
    );
    _emitCheckoutResult(result);
  }

  void _emitCheckoutResult(Result<OrderCheckout> result) {
    switch (result) {
      case Success<OrderCheckout>(value: final checkout):
        emit(CheckoutReady(checkout));
      case ResultFailure<OrderCheckout>(
          message: final message,
          cause: final cause,
        ):
        emit(CheckoutFailure(cause ?? message));
    }
  }

  Future<void> handleCheckoutReturn({
    required OrderCheckout checkout,
    required Uri callbackUri,
  }) async {
    switch (_checkoutReturnKind(callbackUri, checkout)) {
      case _CheckoutReturnKind.cancelled:
        emit(const CheckoutCancelled());
        return;
      case _CheckoutReturnKind.invalid:
        emit(const CheckoutInvalidReturn());
        return;
      case _CheckoutReturnKind.success:
        break;
    }

    emit(const CheckoutVerifying());
    Object? lastFailure;

    for (int attempt = 0; attempt < _verificationAttempts; attempt++) {
      if (isClosed) return;
      final Result<AccountOrder> result = await _getOrder(
        GetOrderParams(checkout.orderId),
      );
      if (isClosed) return;

      switch (result) {
        case Success<AccountOrder>(value: final order):
          lastFailure = null;
          if (order.paymentStatus == 1) {
            emit(CheckoutPaid(order));
            return;
          }
          if (order.paymentStatus >= 2) {
            emit(const CheckoutPaymentFailed());
            return;
          }
        case ResultFailure<AccountOrder>(
            message: final message,
            cause: final cause,
          ):
          lastFailure = cause ?? message;
      }

      if (attempt < _verificationAttempts - 1) {
        await _verificationDelay(_verificationInterval);
      }
    }

    if (isClosed) return;
    if (lastFailure != null) {
      emit(CheckoutFailure(lastFailure));
    } else {
      emit(const CheckoutPaymentPending());
    }
  }

  void markCheckoutCancelled() {
    if (!isClosed) emit(const CheckoutCancelled());
  }

  void reset() {
    if (!isClosed) emit(const CheckoutInitial());
  }
}

enum _CheckoutReturnKind { success, cancelled, invalid }

_CheckoutReturnKind _checkoutReturnKind(Uri uri, OrderCheckout checkout) {
  if (uri.scheme.toLowerCase() != Env.checkoutCallbackScheme ||
      uri.host.toLowerCase() != Env.checkoutCallbackHost) {
    return _CheckoutReturnKind.invalid;
  }

  final String returnedOrderId =
      uri.queryParameters['orderId']?.trim() ?? '';
  if (returnedOrderId.isEmpty ||
      returnedOrderId.toLowerCase() != checkout.orderId.toLowerCase()) {
    return _CheckoutReturnKind.invalid;
  }

  switch (uri.path) {
    case '/cancel':
      return _CheckoutReturnKind.cancelled;
    case '/success':
      final String returnedSessionId =
          (uri.queryParameters['sessionId'] ??
                  uri.queryParameters['session_id'])
              ?.trim() ??
          '';
      if (returnedSessionId.isNotEmpty &&
          (checkout.checkoutSessionId.isEmpty ||
              returnedSessionId != checkout.checkoutSessionId)) {
        return _CheckoutReturnKind.invalid;
      }
      return _CheckoutReturnKind.success;
    default:
      return _CheckoutReturnKind.invalid;
  }
}
