import '../../../../core/use_cases/use_case.dart';
import '../entities/book_rating_summary.dart';
import '../repositories/book_engagement_repository.dart';

class GetBookRatingUseCase extends UseCase<BookRatingSummary, String> {
  const GetBookRatingUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<BookRatingSummary> call(String params) =>
      _repository.getRating(params);
}
