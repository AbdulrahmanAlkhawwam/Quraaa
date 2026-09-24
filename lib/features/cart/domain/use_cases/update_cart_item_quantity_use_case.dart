import 'package:equatable/equatable.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase
    extends UseCase<CartSummary, UpdateCartItemQuantityParams> {
  const UpdateCartItemQuantityUseCase(this._repository);

  final CartRepository _repository;

  @override
  FutureEither<CartSummary> call(UpdateCartItemQuantityParams params) {
    return _repository.updateQuantity(
      listingId: params.itemId,
      quantity: params.quantity,
    );
  }
}

class UpdateCartItemQuantityParams extends Equatable {
  const UpdateCartItemQuantityParams({
    required this.itemId,
    required this.quantity,
  });

  final String itemId;
  final int quantity;

  @override
  List<Object?> get props => <Object?>[itemId, quantity];
}
