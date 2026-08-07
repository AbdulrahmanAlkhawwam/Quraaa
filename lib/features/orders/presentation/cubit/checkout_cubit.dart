import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/env/env.dart';
import '../../../../core/architecture/result.dart';
import '../../../profile/profile.dart';
import '../../domain/entities/order_checkout.dart';
import '../../domain/use_cases/create_order_use_case.dart';

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
    required ProfileRepository profileRepository,
  }) : _createOrder = createOrder,
       _profileRepository = profileRepository,
       super(const CheckoutInitial());

  final CreateOrderUseCase _createOrder;
  final ProfileRepository _profileRepository;

  Future<void> startCheckout() async {
    if (state is CheckoutLoading) return;
    emit(const CheckoutLoading());

    Profile? profile;
    try {
      profile = await _profileRepository.getCachedProfile();
      profile ??= await _profileRepository.getMyProfile();
    } catch (_) {
      // Shipping remains optional in the API contract. The backend will return
      // a concrete validation error if a physical order requires a location.
    }

    final ProfileLocation? location = profile?.location;
    final Result<OrderCheckout> result = await _createOrder(
      CreateOrderParams(
        successUrl: Env.checkoutSuccessUrl,
        cancelUrl: Env.checkoutCancelUrl,
        latitude: location?.latitude,
        longitude: location?.longitude,
      ),
    );
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
