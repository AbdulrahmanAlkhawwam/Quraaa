import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/book_engagement/data/book_engagement_remote_data_source.dart';
import 'package:quraaa/features/book_engagement/domain/book_engagement.dart';

void main() {
  late _RecordingHttpHelper http;
  late BookEngagementRemoteDataSource dataSource;

  setUp(() {
    http = _RecordingHttpHelper();
    dataSource = BookEngagementRemoteDataSource(http);
  });

  test('loads reviews from the OpenAPI reviews endpoint', () async {
    final List<BookComment> comments = await dataSource.getComments('book-1');

    expect(http.lastPath, '/books/book-1/reviews');
    expect(http.lastQuery, <String, dynamic>{'PageNumber': 1, 'PageSize': 20});
    expect(comments.single.id, 'review-1');
    expect(comments.single.name, 'Reader');
    expect(comments.single.score, 4);
    expect(comments.single.content, 'Useful');
  });

  test('creates, updates, and deletes the current user review', () async {
    await dataSource.addReview('book-1', 5, 'Excellent');
    expect(http.lastMethod, 'POST');
    expect(http.lastPath, '/books/book-1/reviews');
    expect(http.lastData, <String, dynamic>{
      'score': 5,
      'content': 'Excellent',
    });

    await dataSource.updateReview('book-1', 3, 'Updated');
    expect(http.lastMethod, 'PUT');
    expect(http.lastPath, '/books/book-1/reviews');
    expect(http.lastData, <String, dynamic>{'score': 3, 'content': 'Updated'});

    await dataSource.deleteReview('book-1');
    expect(http.lastMethod, 'DELETE');
    expect(http.lastPath, '/books/book-1/reviews');
  });
}

class _RecordingHttpHelper extends HttpHelper {
  _RecordingHttpHelper() : super(Dio());

  String? lastMethod;
  String? lastPath;
  Object? lastData;
  Map<String, dynamic>? lastQuery;

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    lastMethod = 'GET';
    lastPath = path;
    lastQuery = queryParameters;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'review-1',
            'userId': 'user-1',
            'userName': 'Reader',
            'userAvatarUrl': '',
            'score': 4,
            'content': 'Useful',
            'creationTimeUtc': '2026-08-16T19:00:00Z',
          },
        ],
        'pageNumber': 1,
        'pageSize': queryParameters?['PageSize'] ?? 20,
        'totalCount': 1,
      },
    );
  }

  @override
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Options? options,
  }) async {
    return _write('POST', path, data);
  }

  @override
  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Options? options,
  }) async {
    return _write('PUT', path, data);
  }

  @override
  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Options? options,
  }) async {
    return _write('DELETE', path, data);
  }

  Response<dynamic> _write(String method, String path, Object? data) {
    lastMethod = method;
    lastPath = path;
    lastData = data;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }
}
