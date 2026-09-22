import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/book_comment.dart';
import '../entities/book_rating_summary.dart';
import '../entities/book_report_reason.dart';

/// Reviews, ratings and abuse reports for a single book.
abstract class BookEngagementRepository {
  FutureEither<List<BookComment>> getComments(String bookId);

  FutureEither<BookRatingSummary> getRating(String bookId);

  /// The signed-in user's own review, or `null` when they have not written one.
  FutureEither<BookComment?> getMyReview(String bookId);

  FutureEither<Unit> addReview(String bookId, int score, String content);

  FutureEither<Unit> updateReview(String bookId, int score, String content);

  FutureEither<Unit> deleteReview(String bookId);

  FutureEither<List<BookReportReason>> getReportReasons();

  FutureEither<Unit> report(String bookId, int reason, String? details);
}
