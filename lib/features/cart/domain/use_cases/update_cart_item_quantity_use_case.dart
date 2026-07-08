import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase
    extends UseCase<Result<CartSummary>, UpdateCartItemQuantityParams> {
  const UpdateCartItemQuantityUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(UpdateCartItemQuantityParams params) {
    return _repository.updateQuantity(
      itemId: params.itemId,
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

