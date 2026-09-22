import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/http_helper.dart';
import '../models/book_comment_model.dart';
import '../models/book_rating_summary_model.dart';
import '../models/book_report_reason_model.dart';

abstract class BookEngagementRemoteDataSource {
  Future<List<BookCommentModel>> getComments(String bookId);

  /// `null` when the signed-in user has not reviewed the book (backend 404).
  Future<BookCommentModel?> getMyReview(String bookId);

  Future<BookRatingSummaryModel> getRating(String bookId);

  Future<void> addReview(String bookId, int score, String content);

  Future<void> updateReview(String bookId, int score, String content);

  Future<void> deleteReview(String bookId);

  Future<List<BookReportReasonModel>> getReportReasons();

  Future<void> report(String bookId, int reason, String? details);
}

class BookEngagementRemoteDataSourceImpl
    implements BookEngagementRemoteDataSource {
  const BookEngagementRemoteDataSourceImpl(this._http);

  final HttpHelper _http;

  @override
  Future<List<BookCommentModel>> getComments(String bookId) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.bookReviews(bookId),
      queryParameters: const <String, dynamic>{'PageNumber': 1, 'PageSize': 20},
    );
    final Object? raw = response.data is Map
        ? (response.data as Map)['items']
        : response.data;
    if (raw is! List) return const <BookCommentModel>[];
    return raw
        .whereType<Map>()
        .map(
          (Map item) =>
              BookCommentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  @override
  Future<BookCommentModel?> getMyReview(String bookId) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.myBookReview(bookId),
      options: Options(
        validateStatus: (int? status) => status == 200 || status == 404,
      ),
    );
    if (response.statusCode == 404) return null;
    if (response.data is! Map) return null;
    return BookCommentModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<BookRatingSummaryModel> getRating(String bookId) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.bookReviews(bookId),
      queryParameters: const <String, dynamic>{
        'PageNumber': 1,
        'PageSize': 100,
      },
    );
    return BookRatingSummaryModel.fromReviewsPage(
      response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{},
    );
  }

  @override
  Future<void> addReview(String bookId, int score, String content) async {
    await _http.post(
      ApiEndpoints.bookReviews(bookId),
      data: <String, dynamic>{'score': score, 'content': content},
    );
  }

  @override
  Future<void> updateReview(String bookId, int score, String content) async {
    await _http.put(
      ApiEndpoints.bookReviews(bookId),
      data: <String, dynamic>{'score': score, 'content': content},
    );
  }

  @override
  Future<void> deleteReview(String bookId) async {
    await _http.delete(ApiEndpoints.bookReviews(bookId));
  }

  @override
  Future<List<BookReportReasonModel>> getReportReasons() async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.bookReportReasons,
    );
    final Object? raw = response.data;
    if (raw is! List) return const <BookReportReasonModel>[];
    return raw
        .whereType<Map>()
        .map(
          (Map item) =>
              BookReportReasonModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  @override
  Future<void> report(String bookId, int reason, String? details) async {
    await _http.post(
      ApiEndpoints.bookReports(bookId),
      data: <String, dynamic>{
        'reason': reason,
        if (details?.trim().isNotEmpty == true) 'details': details!.trim(),
      },
    );
  }
}
