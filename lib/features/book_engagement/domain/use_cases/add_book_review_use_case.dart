import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/book_engagement_repository.dart';

class BookReviewParams {
  const BookReviewParams({
    required this.bookId,
    required this.score,
    required this.content,
  });

  final String bookId;
  final int score;
  final String content;
}

class AddBookReviewUseCase extends UseCase<Unit, BookReviewParams> {
  const AddBookReviewUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<Unit> call(BookReviewParams params) =>
      _repository.addReview(params.bookId, params.score, params.content);
}
