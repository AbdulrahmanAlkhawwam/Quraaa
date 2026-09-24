import 'package:equatable/equatable.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/checkout_confirmation.dart';
import '../repositories/orders_repository.dart';

class ConfirmCheckoutUseCase
    extends UseCase<CheckoutConfirmation, ConfirmCheckoutParams> {
  const ConfirmCheckoutUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  FutureEither<CheckoutConfirmation> call(ConfirmCheckoutParams params) {
    return _repository.confirmCheckout(params.sessionId);
  }
}

class ConfirmCheckoutParams extends Equatable {
  const ConfirmCheckoutParams(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => <Object?>[sessionId];
}
