import '../../../core/architecture/result.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../domain/book_engagement.dart';
import 'book_engagement_remote_data_source.dart';

class BookEngagementRepositoryImpl implements BookEngagementRepository {
  const BookEngagementRepositoryImpl(this._remote);

  final BookEngagementRemoteDataSource _remote;

  @override
  Future<Result<List<BookComment>>> getComments(String bookId) =>
      _result(() => _remote.getComments(bookId));

  @override
  Future<Result<BookRatingSummary>> getRating(String bookId) =>
      _result(() => _remote.getRating(bookId));

  @override
  Future<Result<BookComment?>> getMyReview(String bookId) =>
      _result(() => _remote.getMyReview(bookId));
  @override
  Future<Result<void>> addReview(String bookId, int score, String content) =>
      _result(() => _remote.addReview(bookId, score, content));

  @override
  Future<Result<void>> updateReview(String bookId, int score, String content) =>
      _result(() => _remote.updateReview(bookId, score, content));

  @override
  Future<Result<void>> deleteReview(String bookId) =>
      _result(() => _remote.deleteReview(bookId));
  @override
  Future<Result<List<BookReportReason>>> getReportReasons() =>
      _result(_remote.getReportReasons);

  @override
  Future<Result<void>> report(String bookId, int reason, String? details) =>
      _result(() => _remote.report(bookId, reason, details));

  Future<Result<T>> _result<T>(Future<T> Function() request) async {
    try {
      return Success<T>(await request());
    } catch (error) {
      final Failure failure = ErrorMapper.map(error);
      return ResultFailure<T>(failure.message, cause: failure);
    }
  }
}
