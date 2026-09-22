import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/book_engagement_repository.dart';

class ReportBookParams {
  const ReportBookParams({
    required this.bookId,
    required this.reason,
    this.details,
  });

  final String bookId;
  final int reason;
  final String? details;
}

class ReportBookUseCase extends UseCase<Unit, ReportBookParams> {
  const ReportBookUseCase(this._repository);

  final BookEngagementRepository _repository;

  @override
  FutureEither<Unit> call(ReportBookParams params) =>
      _repository.report(params.bookId, params.reason, params.details);
}
