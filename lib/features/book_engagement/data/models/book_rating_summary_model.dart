import '../../domain/entities/book_rating_summary.dart';
import 'book_comment_model.dart';

class BookRatingSummaryModel extends BookRatingSummary {
  const BookRatingSummaryModel({required super.average, required super.count});

  /// The backend has no rating endpoint, so the summary is derived from a page
  /// of reviews: the mean of the positive scores, and the page's total count.
  factory BookRatingSummaryModel.fromReviewsPage(Map<String, dynamic> page) {
    final Object? items = page['items'];
    final List<int> scores = (items is List ? items : const <dynamic>[])
        .whereType<Map>()
        .map((Map item) => BookCommentModel.parseInt(item['score']))
        .where((int score) => score > 0)
        .toList(growable: false);
    final double average = scores.isEmpty
        ? 0
        : scores.reduce((int left, int right) => left + right) / scores.length;
    return BookRatingSummaryModel(
      average: average,
      count: BookCommentModel.parseInt(page['totalCount']),
    );
  }
}
