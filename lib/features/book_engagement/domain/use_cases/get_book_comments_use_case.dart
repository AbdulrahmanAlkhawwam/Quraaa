import '../../../../core/use_cases/use_case.dart';
import '../entities/book_comment.dart';
import '../repositories/book_engagement_repository.dart';

class GetBookCommentsUseCase extends UseCase<List<BookComment>, String> {
  const GetBookCommentsUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<List<BookComment>> call(String params) =>
      _repository.getComments(params);
}
