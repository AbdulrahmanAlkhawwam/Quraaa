import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/book_assistant_repository.dart';

class SummarizePurchaseUseCase
    extends UseCase<Result<String>, SummarizePurchaseParams> {
  const SummarizePurchaseUseCase(this._repository);

  final BookAssistantRepository _repository;

  @override
  Future<Result<String>> call(SummarizePurchaseParams params) {
    return _repository.summarize(purchaseId: params.purchaseId);
  }
}

class SummarizePurchaseParams extends Equatable {
  const SummarizePurchaseParams(this.purchaseId);

  final String purchaseId;

  @override
  List<Object?> get props => <Object?>[purchaseId];
}
