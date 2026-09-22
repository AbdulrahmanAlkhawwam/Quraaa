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
    when(() => httpHelper.get(
          ApiEndpoints.homeCatalog,
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
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
    expect(result.single.format, BookFormat.used);
    verify(() => httpHelper.get(
          ApiEndpoints.homeCatalog,
          queryParameters: any(named: 'queryParameters'),
        )).called(1);
  });

  test('accepts a direct catalog list response', () async {
    when(() => httpHelper.get(
          ApiEndpoints.homeCatalog,
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
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

  test('sends all selected filters as API query parameters', () async {
    when(
      () => httpHelper.get(
        ApiEndpoints.homeCatalog,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: <Map<String, dynamic>>[],
      ),
    );

    await dataSource.fetchHomeCatalog(
      filter: const BookCatalogFilter(
        libraryId: 'library-1',
        categoryId: 'category-1',
        format: ListingFormat.physical,
        sellerType: SellerType.library,
        condition: BookCondition.likeNew,
        minPrice: 10,
        maxPrice: 25,
      ),
    );

    final Map<String, dynamic> query = verify(
      () => httpHelper.get(
        ApiEndpoints.homeCatalog,
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(query, containsPair('LibraryId', 'library-1'));
    expect(query, containsPair('CategoryId', 'category-1'));
    expect(query, containsPair('Format', 2));
    expect(query, containsPair('SellerType', 1));
    expect(query, containsPair('Condition', 2));
    expect(query, containsPair('MinPrice', 10.0));
    expect(query, containsPair('MaxPrice', 25.0));
  });
  test('rejects an invalid response shape', () async {
    when(() => httpHelper.get(
          ApiEndpoints.homeCatalog,
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
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
