import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../profile/profile.dart';
import '../../domain/entities/checkout_confirmation.dart';
import '../../domain/entities/order_checkout.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../../domain/use_cases/create_order_use_case.dart';
import '../../domain/use_cases/get_order_checkout_context_use_case.dart';
import '../../domain/use_cases/confirm_checkout_use_case.dart';
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
  const CheckoutPaid(this.confirmation);

  final CheckoutConfirmation confirmation;
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
    required ConfirmCheckoutUseCase confirmCheckout,
    required ResumePendingOrderCheckoutUseCase resumePendingOrderCheckout,
    required ProfileRepository profileRepository,
    Duration verificationInterval = const Duration(seconds: 1),
    int verificationAttempts = 5,
    CheckoutDelay verificationDelay = _defaultCheckoutDelay,
  })  : assert(verificationAttempts > 0),
        _createOrder = createOrder,
        _getCheckoutContext = getCheckoutContext,
        _confirmCheckout = confirmCheckout,
        _resumePendingOrderCheckout = resumePendingOrderCheckout,
        _profileRepository = profileRepository,
        _verificationInterval = verificationInterval,
        _verificationAttempts = verificationAttempts,
        _verificationDelay = verificationDelay,
        super(const CheckoutInitial());

  final CreateOrderUseCase _createOrder;
  final GetOrderCheckoutContextUseCase _getCheckoutContext;
  final ConfirmCheckoutUseCase _confirmCheckout;
  final ResumePendingOrderCheckoutUseCase _resumePendingOrderCheckout;
  final ProfileRepository _profileRepository;
  final Duration _verificationInterval;
  final int _verificationAttempts;
  final CheckoutDelay _verificationDelay;

  Future<void> startCheckout({String? shippingLocationId}) async {
    if (state is CheckoutLoading) return;
    emit(const CheckoutLoading());

    final Either<Failure, OrderCheckoutContext> contextResult =
        await _getCheckoutContext();
    final OrderCheckoutContext? loadedContext = contextResult.toNullable();
    if (loadedContext == null) {
      emit(CheckoutFailure(contextResult.getLeft().toNullable()!));
      return;
    }
    final OrderCheckoutContext checkoutContext = loadedContext;
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
      // Failures are ignored on purpose: the backend returns a validation
      // error if a physical order still has no usable shipping location.
      profile = await (await _profileRepository.getCachedProfile()).fold(
        (_) async => null,
        (Profile? cached) async =>
            cached ?? (await _profileRepository.getMyProfile()).toNullable(),
      );
    }

    final ProfileLocation? location = profile?.location;
    final Either<Failure, OrderCheckout> result = await _createOrder(
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
    final Either<Failure, OrderCheckout> result =
        await _resumePendingOrderCheckout();
    _emitCheckoutResult(result);
  }

  void _emitCheckoutResult(Either<Failure, OrderCheckout> result) {
    emit(
      result.fold(
        (Failure failure) => CheckoutFailure(failure),
        (OrderCheckout checkout) => CheckoutReady(checkout),
      ),
    );
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
      final Either<Failure, CheckoutConfirmation> result =
          await _confirmCheckout(
            ConfirmCheckoutParams(checkout.checkoutSessionId),
          );
      if (isClosed) return;

      final CheckoutConfirmation? confirmation = result.toNullable();
      if (confirmation == null) {
        lastFailure = result.getLeft().toNullable();
      } else {
        lastFailure = null;
        if (confirmation.orderId.toLowerCase() !=
            checkout.orderId.toLowerCase()) {
          emit(
            CheckoutFailure(
              StateError('Checkout confirmation returned another order.'),
            ),
          );
          return;
        }
        if (confirmation.paid) {
          emit(CheckoutPaid(confirmation));
          return;
        }
        if (!confirmation.pending) {
          emit(const CheckoutPaymentFailed());
          return;
        }
      }

      if (attempt < _verificationAttempts - 1) {
        await _verificationDelay(_verificationInterval);
      }
    }

    if (isClosed) return;
    if (lastFailure != null) {
      emit(CheckoutFailure(lastFailure));
    } else {
      emit(const CheckoutPaymentFailed());
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
  if (uri.scheme.toLowerCase() != AppConfig.checkoutCallbackScheme ||
      uri.host.toLowerCase() != AppConfig.checkoutCallbackHost) {
    return _CheckoutReturnKind.invalid;
  }

  final String returnedOrderId = uri.queryParameters['orderId']?.trim() ?? '';
  if (returnedOrderId.isEmpty ||
      returnedOrderId.toLowerCase() != checkout.orderId.toLowerCase()) {
    return _CheckoutReturnKind.invalid;
  }

  switch (uri.path) {
    case '/cancel':
      return _CheckoutReturnKind.cancelled;
    case '/success':
      return _CheckoutReturnKind.success;
    default:
      return _CheckoutReturnKind.invalid;
  }
}
