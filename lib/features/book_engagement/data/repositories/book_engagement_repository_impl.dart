import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/book_comment.dart';
import '../../domain/entities/book_rating_summary.dart';
import '../../domain/entities/book_report_reason.dart';
import '../../domain/repositories/book_engagement_repository.dart';
import '../data_sources/book_engagement_remote_data_source.dart';

class BookEngagementRepositoryImpl implements BookEngagementRepository {
  const BookEngagementRepositoryImpl(this._remote);

  final BookEngagementRemoteDataSource _remote;

  @override
  FutureEither<List<BookComment>> getComments(String bookId) =>
      _guard(() => _remote.getComments(bookId));

  @override
  FutureEither<BookRatingSummary> getRating(String bookId) =>
      _guard(() => _remote.getRating(bookId));

  @override
  FutureEither<BookComment?> getMyReview(String bookId) =>
      _guard(() => _remote.getMyReview(bookId));

  @override
  FutureEither<Unit> addReview(String bookId, int score, String content) =>
      _guardUnit(() => _remote.addReview(bookId, score, content));

  @override
  FutureEither<Unit> updateReview(String bookId, int score, String content) =>
      _guardUnit(() => _remote.updateReview(bookId, score, content));

  @override
  FutureEither<Unit> deleteReview(String bookId) =>
      _guardUnit(() => _remote.deleteReview(bookId));

  @override
  FutureEither<List<BookReportReason>> getReportReasons() =>
      _guard(_remote.getReportReasons);

  @override
  FutureEither<Unit> report(String bookId, int reason, String? details) =>
      _guardUnit(() => _remote.report(bookId, reason, details));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  FutureEither<Unit> _guardUnit(Future<void> Function() request) =>
      _guard(() async {
        await request();
        return unit;
      });
}
