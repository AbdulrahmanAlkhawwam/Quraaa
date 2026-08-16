import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/home/data/datasources/home_books_remote_data_source.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  late _MockHttpHelper httpHelper;
  late HomeBooksRemoteDataSourceImpl dataSource;

  final Map<String, dynamic> response = <String, dynamic>{
    'items': <Map<String, dynamic>>[
      <String, dynamic>{
        'listingId': 'listing-id',
        'title': 'Book title',
        'author': 'Author',
        'coverImageUrl': 'https://example.com/cover.jpg',
      },
    ],
    'pageNumber': '1',
    'pageSize': '10',
    'totalCount': '1',
    'totalPages': '1',
    'hasNextPage': false,
    'hasPreviousPage': false,
  };

  setUp(() {
    httpHelper = _MockHttpHelper();
    dataSource = HomeBooksRemoteDataSourceImpl(httpHelper);
  });

  test('loads recommended books from the recommended endpoint', () async {
    when(() => httpHelper.get(ApiEndpoints.recommendedBooks)).thenAnswer(
      (_) async => Response<dynamic>(
        data: response,
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final result = await dataSource.getRecommendedBooks();

    expect(result.items.single.listingId, 'listing-id');
    verify(() => httpHelper.get(ApiEndpoints.recommendedBooks)).called(1);
  });

  test('loads popular books from the most-popular endpoint', () async {
    when(() => httpHelper.get(ApiEndpoints.mostPopularBooks)).thenAnswer(
      (_) async => Response<dynamic>(
        data: response,
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final result = await dataSource.getMostPopularBooks();

    expect(result.items.single.title, 'Book title');
    verify(() => httpHelper.get(ApiEndpoints.mostPopularBooks)).called(1);
  });

  test('rejects an invalid response shape', () async {
    when(() => httpHelper.get(ApiEndpoints.recommendedBooks)).thenAnswer(
      (_) async => Response<dynamic>(
        data: <dynamic>[],
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await expectLater(
      dataSource.getRecommendedBooks,
      throwsA(isA<UnknownException>()),
    );
  });
}
