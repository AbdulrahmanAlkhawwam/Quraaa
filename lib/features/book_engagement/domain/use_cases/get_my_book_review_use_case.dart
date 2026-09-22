import '../../../../core/use_cases/use_case.dart';
import '../entities/book_comment.dart';
import '../repositories/book_engagement_repository.dart';

class GetMyBookReviewUseCase extends UseCase<BookComment?, String> {
  const GetMyBookReviewUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<BookComment?> call(String params) =>
      _repository.getMyReview(params);
}
