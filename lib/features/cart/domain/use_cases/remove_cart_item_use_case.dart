import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase
    extends UseCase<Result<CartSummary>, RemoveCartItemParams> {
  const RemoveCartItemUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(RemoveCartItemParams params) {
    return _repository.removeItem(params.itemId);
  }
}

class RemoveCartItemParams extends Equatable {
  const RemoveCartItemParams(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => <Object?>[itemId];
}

