import 'package:equatable/equatable.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/book_assistant_repository.dart';

class SummarizePurchaseUseCase
    extends UseCase<String, SummarizePurchaseParams> {
  const SummarizePurchaseUseCase(this._repository);

  final BookAssistantRepository _repository;

  @override
  FutureEither<String> call(SummarizePurchaseParams params) {
    return _repository.summarize(purchaseId: params.purchaseId);
  }
}

class SummarizePurchaseParams extends Equatable {
  const SummarizePurchaseParams(this.purchaseId);

  final String purchaseId;

  @override
  List<Object?> get props => <Object?>[purchaseId];
}
