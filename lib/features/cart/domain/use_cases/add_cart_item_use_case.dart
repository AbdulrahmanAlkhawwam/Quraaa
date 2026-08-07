import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/cart_item.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class AddCartItemUseCase
    extends UseCase<Result<CartSummary>, AddCartItemParams> {
  const AddCartItemUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(AddCartItemParams params) {
    return _repository.addItem(
      listingId: params.listingId,
      quantity: params.quantity,
      metadata: params.metadata,
    );
  }
}

class AddCartItemParams extends Equatable {
  const AddCartItemParams({
    required this.listingId,
    this.quantity = 1,
    this.metadata,
  });

  final String listingId;
  final int quantity;
  final CartItem? metadata;

  @override
  List<Object?> get props => <Object?>[listingId, quantity, metadata];
}
