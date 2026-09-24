import 'package:equatable/equatable.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase
    extends UseCase<CartSummary, RemoveCartItemParams> {
  const RemoveCartItemUseCase(this._repository);

  final CartRepository _repository;

  @override
  FutureEither<CartSummary> call(RemoveCartItemParams params) {
    return _repository.removeItem(params.itemId);
  }
}

class RemoveCartItemParams extends Equatable {
  const RemoveCartItemParams(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => <Object?>[itemId];
}

