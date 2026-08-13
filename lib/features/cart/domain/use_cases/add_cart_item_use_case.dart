import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class AddCartItemUseCase
    extends UseCase<Result<CartSummary>, AddCartItemParams> {
  const AddCartItemUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(AddCartItemParams params) =>
      _repository.addItem(
        listingId: params.listingId,
        quantity: params.quantity,
      );
}

class AddCartItemParams extends Equatable {
  const AddCartItemParams({required this.listingId, required this.quantity});

  final String listingId;
  final int quantity;

  @override
  List<Object?> get props => <Object?>[listingId, quantity];
}
