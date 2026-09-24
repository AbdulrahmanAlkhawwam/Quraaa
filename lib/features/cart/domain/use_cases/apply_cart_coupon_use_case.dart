import 'package:equatable/equatable.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class ApplyCartCouponUseCase
    extends UseCase<CartSummary, ApplyCartCouponParams> {
  const ApplyCartCouponUseCase(this._repository);

  final CartRepository _repository;

  @override
  FutureEither<CartSummary> call(ApplyCartCouponParams params) {
    return _repository.getCart();
  }
}

class ApplyCartCouponParams extends Equatable {
  const ApplyCartCouponParams(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}
