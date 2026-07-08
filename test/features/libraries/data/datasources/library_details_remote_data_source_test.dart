import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/libraries/data/datasources/library_details_remote_data_source.dart';
import 'package:quraaa/features/libraries/data/models/paginated_library_books_response_model.dart';

class MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  group('LibraryDetailsRemoteDataSourceImpl', () {
    late MockHttpHelper httpHelper;
    late LibraryDetailsRemoteDataSourceImpl dataSource;

    const String libraryId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

    setUp(() {
      httpHelper = MockHttpHelper();
      dataSource = LibraryDetailsRemoteDataSourceImpl(httpHelper);
    });

    final Map<String, dynamic> responseJson = <String, dynamic>{
      'items': <Map<String, dynamic>>[
        const <String, dynamic>{
          'listingId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          'price': '10.00',
          'stock': '5',
          'condition': 0,
          'book': <String, dynamic>{
            'bookId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
            'title': 'Emar English book',
            'author': 'Ahmed Khaled',
            'description': 'A great book',
            'coverImageUrl': 'https://example.com/cover.png',
            'language': 'English',
            'isbn': '123456789',
            'category': <String, dynamic>{
              'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
              'nameAr': 'تعليم',
              'nameEn': 'Education',
            },
          },
        },
      ],
      'pageNumber': 1,
      'pageSize': 10,
      'totalCount': 1,
      'totalPages': 1,
      'hasNextPage': false,
      'hasPreviousPage': false,
    };

    test('returns paginated response on successful fetch', () async {
      when(
        () => httpHelper.get(
          ApiEndpoints.libraryBooks(libraryId),
          queryParameters: <String, dynamic>{
            'PageNumber': 1,
            'PageSize': 10,
          },
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final PaginatedLibraryBooksResponseModel result =
          await dataSource.getLibraryBooks(
        libraryId: libraryId,
        pageNumber: 1,
        pageSize: 10,
      );

      expect(result.items.length, 1);
      expect(result.items.first.title, 'Emar English book');
      expect(result.items.first.author, 'Ahmed Khaled');
      expect(result.pageNumber, 1);
      expect(result.hasNextPage, false);
      verify(
        () => httpHelper.get(
          ApiEndpoints.libraryBooks(libraryId),
          queryParameters: <String, dynamic>{
            'PageNumber': 1,
            'PageSize': 10,
          },
        ),
      ).called(1);
    });

    test('sends optional query parameters when provided', () async {
      when(
        () => httpHelper.get(
          ApiEndpoints.libraryBooks(libraryId),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: responseJson,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await dataSource.getLibraryBooks(
        libraryId: libraryId,
        pageNumber: 2,
        pageSize: 20,
        searchTerm: 'history',
        sortBy: 'title',
        sortDescending: true,
      );

      verify(
        () => httpHelper.get(
          ApiEndpoints.libraryBooks(libraryId),
          queryParameters: <String, dynamic>{
            'PageNumber': 2,
            'PageSize': 20,
            'SearchTerm': 'history',
            'SortBy': 'title',
            'SortDescending': true,
          },
        ),
      ).called(1);
    });

    test('throws UnknownException on invalid response shape', () async {
      when(
        () => httpHelper.get(
          ApiEndpoints.libraryBooks(libraryId),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: <dynamic>[],
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await expectLater(
        () => dataSource.getLibraryBooks(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
        ),
        throwsA(isA<UnknownException>()),
      );
    });

    test('throws UnknownException on DioException', () async {
      when(
        () => httpHelper.get(
          ApiEndpoints.libraryBooks(libraryId),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Connection refused',
        ),
      );

      await expectLater(
        () => dataSource.getLibraryBooks(
          libraryId: libraryId,
          pageNumber: 1,
          pageSize: 10,
        ),
        throwsA(isA<UnknownException>()),
      );
    });
  });
}
