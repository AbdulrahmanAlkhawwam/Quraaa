import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/books/books.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  late _MockHttpHelper httpHelper;
  late BooksRemoteDataSource dataSource;

  setUp(() {
    httpHelper = _MockHttpHelper();
    dataSource = BooksRemoteDataSourceImpl(httpHelper);
  });

  test('gets home catalog and parses a wrapped items response', () async {
    when(() => httpHelper.get(ApiEndpoints.homeCatalog)).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: <String, dynamic>{
          'data': <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'listingId': 'listing-1',
                'price': 15,
                'format': 2,
                'book': <String, dynamic>{
                  'bookId': 'book-1',
                  'title': 'Global English',
                },
              },
            ],
          },
        },
      ),
    );

    final List<HomeCatalogBookModel> result =
        await dataSource.fetchHomeCatalog();

    expect(result, hasLength(1));
    expect(result.single.id, 'book-1');
    expect(result.single.listingId, 'listing-1');
    expect(result.single.format, BookFormat.audio);
    verify(() => httpHelper.get(ApiEndpoints.homeCatalog)).called(1);
  });

  test('accepts a direct catalog list response', () async {
    when(() => httpHelper.get(ApiEndpoints.homeCatalog)).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: <Map<String, dynamic>>[
          <String, dynamic>{'bookId': 'book-1', 'title': 'Book'},
        ],
      ),
    );

    final List<HomeCatalogBookModel> result =
        await dataSource.fetchHomeCatalog();

    expect(result.single.title, 'Book');
  });

  test('rejects an invalid response shape', () async {
    when(() => httpHelper.get(ApiEndpoints.homeCatalog)).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: 'invalid',
      ),
    );

    await expectLater(
      dataSource.fetchHomeCatalog(),
      throwsA(isA<UnknownException>()),
    );
  });
}
