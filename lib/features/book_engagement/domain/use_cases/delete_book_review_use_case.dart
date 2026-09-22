import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/book_engagement_repository.dart';

class DeleteBookReviewUseCase extends UseCase<Unit, String> {
  const DeleteBookReviewUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<Unit> call(String params) => _repository.deleteReview(params);
}
