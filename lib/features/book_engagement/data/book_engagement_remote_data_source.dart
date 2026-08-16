import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_helper.dart';
import '../domain/book_engagement.dart';

class BookEngagementRemoteDataSource {
  const BookEngagementRemoteDataSource(this._http);

  final HttpHelper _http;

  Future<List<BookComment>> getComments(String bookId) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.bookReviews(bookId),
      queryParameters: const <String, dynamic>{'PageNumber': 1, 'PageSize': 20},
    );
    final Object? raw =
        response.data is Map ? (response.data as Map)['items'] : response.data;
    if (raw is! List) return const <BookComment>[];
    return raw.whereType<Map>().map((Map item) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(item);
      return _comment(json);
    }).toList(growable: false);
  }

  Future<BookComment?> getMyReview(String bookId) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.myBookReview(bookId),
      options: Options(
        validateStatus: (int? status) => status == 200 || status == 404,
      ),
    );
    if (response.statusCode == 404) return null;
    if (response.data is! Map) return null;
    return _comment(Map<String, dynamic>.from(response.data as Map));
  }

  Future<BookRatingSummary> getRating(String bookId) async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.bookReviews(bookId),
      queryParameters: const <String, dynamic>{
        'PageNumber': 1,
        'PageSize': 100,
      },
    );
    final Map<String, dynamic> page = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : const <String, dynamic>{};
    final List<int> scores =
        (page['items'] is List ? page['items'] as List : const <dynamic>[])
            .whereType<Map>()
            .map((Map item) => _integer(item['score']))
            .where((int score) => score > 0)
            .toList(growable: false);
    final double average = scores.isEmpty
        ? 0
        : scores.reduce((int left, int right) => left + right) / scores.length;
    return BookRatingSummary(
      average: average,
      count: _integer(page['totalCount']),
    );
  }

  Future<void> addReview(String bookId, int score, String content) async {
    await _http.post(
      ApiEndpoints.bookReviews(bookId),
      data: <String, dynamic>{'score': score, 'content': content},
    );
  }

  Future<void> updateReview(String bookId, int score, String content) async {
    await _http.put(
      ApiEndpoints.bookReviews(bookId),
      data: <String, dynamic>{'score': score, 'content': content},
    );
  }

  Future<void> deleteReview(String bookId) async {
    await _http.delete(ApiEndpoints.bookReviews(bookId));
  }

  Future<List<BookReportReason>> getReportReasons() async {
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.bookReportReasons,
    );
    final Object? raw = response.data;
    if (raw is! List) return const <BookReportReason>[];
    return raw.whereType<Map>().map((Map item) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(item);
      return BookReportReason(
        value: _integer(json['reason']),
        nameEn: json['nameEn']?.toString() ?? '',
        nameAr: json['nameAr']?.toString() ?? '',
        requiresDetails: json['requiresDetails'] == true,
      );
    }).toList(growable: false);
  }

  Future<void> report(String bookId, int reason, String? details) async {
    await _http.post(
      ApiEndpoints.bookReports(bookId),
      data: <String, dynamic>{
        'reason': reason,
        if (details?.trim().isNotEmpty == true) 'details': details!.trim(),
      },
    );
  }

  BookComment _comment(Map<String, dynamic> json) => BookComment(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        name: json['userName']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        score: _integer(json['score']),
        createdAt: DateTime.tryParse(
          json['creationTimeUtc']?.toString() ?? '',
        ),
      );
  int _integer(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
}
