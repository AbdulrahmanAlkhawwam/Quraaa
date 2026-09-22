import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/book_engagement_repository.dart';
import 'add_book_review_use_case.dart';

class UpdateBookReviewUseCase extends UseCase<Unit, BookReviewParams> {
  const UpdateBookReviewUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<Unit> call(BookReviewParams params) =>
      _repository.updateReview(params.bookId, params.score, params.content);
}
