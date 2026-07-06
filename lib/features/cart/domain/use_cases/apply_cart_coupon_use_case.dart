import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class ApplyCartCouponUseCase
    extends UseCase<Result<CartSummary>, ApplyCartCouponParams> {
  const ApplyCartCouponUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(ApplyCartCouponParams params) {
    return _repository.applyCoupon(params.code);
  }
}

class ApplyCartCouponParams extends Equatable {
  const ApplyCartCouponParams(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

