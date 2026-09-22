import '../../../../core/use_cases/use_case.dart';
import '../entities/book_report_reason.dart';
import '../repositories/book_engagement_repository.dart';

class GetBookReportReasonsUseCase
    extends NoParamsUseCase<List<BookReportReason>> {
  const GetBookReportReasonsUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<List<BookReportReason>> call() => _repository.getReportReasons();
}
