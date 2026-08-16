import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/env/env.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../profile/profile.dart';
import '../../domain/entities/order_checkout.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../../domain/use_cases/create_order_use_case.dart';
import '../../domain/use_cases/get_order_checkout_context_use_case.dart';
import '../../domain/use_cases/resume_pending_order_checkout_use_case.dart';

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

final class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.error);

  final Object error;
}

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required CreateOrderUseCase createOrder,
    required GetOrderCheckoutContextUseCase getCheckoutContext,
    required ResumePendingOrderCheckoutUseCase resumePendingOrderCheckout,
    required ProfileRepository profileRepository,
  })  : _createOrder = createOrder,
        _getCheckoutContext = getCheckoutContext,
        _resumePendingOrderCheckout = resumePendingOrderCheckout,
        _profileRepository = profileRepository,
        super(const CheckoutInitial());

  final CreateOrderUseCase _createOrder;
  final GetOrderCheckoutContextUseCase _getCheckoutContext;
  final ResumePendingOrderCheckoutUseCase _resumePendingOrderCheckout;
  final ProfileRepository _profileRepository;

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
        successUrl: Env.checkoutSuccessUrl,
        cancelUrl: Env.checkoutCancelUrl,
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
      ResumePendingOrderCheckoutParams(
        successUrl: Env.checkoutSuccessUrl,
        cancelUrl: Env.checkoutCancelUrl,
      ),
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

  void reset() => emit(const CheckoutInitial());
}
