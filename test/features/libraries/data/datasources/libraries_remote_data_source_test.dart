import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/libraries/data/datasources/libraries_remote_data_source.dart';
import 'package:quraaa/features/libraries/data/models/paginated_libraries_response_model.dart';

class MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  group('LibrariesRemoteDataSourceImpl', () {
    late MockHttpHelper httpHelper;
    late LibrariesRemoteDataSourceImpl dataSource;

    setUp(() {
      httpHelper = MockHttpHelper();
      dataSource = LibrariesRemoteDataSourceImpl(httpHelper);
    });

    final Map<String, dynamic> responseJson = <String, dynamic>{
      'items': <Map<String, dynamic>>[
        const <String, dynamic>{
          'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          'libraryName': 'Jarir Book Store',
          'location': 'Riyadh',
          'libraryImage': 'https://example.com/library.png',
          'headerImage': 'https://example.com/header.png',
          'email': 'contact@jarir.com',
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
          ApiEndpoints.libraries,
          queryParameters: <String, dynamic>{
            'SearchTerm': 'jarir',
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

      final PaginatedLibrariesResponseModel result =
          await dataSource.getLibraries(
        searchTerm: 'jarir',
        pageNumber: 1,
        pageSize: 10,
      );

      expect(result.items.length, 1);
      expect(result.items.first.libraryName, 'Jarir Book Store');
      expect(result.pageNumber, 1);
      expect(result.hasNextPage, false);
      verify(
        () => httpHelper.get(
          ApiEndpoints.libraries,
          queryParameters: <String, dynamic>{
            'SearchTerm': 'jarir',
            'PageNumber': 1,
            'PageSize': 10,
          },
        ),
      ).called(1);
    });

    test('throws UnknownException on invalid response shape', () async {
      when(
        () => httpHelper.get(
          ApiEndpoints.libraries,
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
        () => dataSource.getLibraries(
          searchTerm: '',
          pageNumber: 1,
          pageSize: 10,
        ),
        throwsA(isA<UnknownException>()),
      );
    });

    test('throws UnknownException on DioException', () async {
      when(
        () => httpHelper.get(
          ApiEndpoints.libraries,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Connection refused',
        ),
      );

      await expectLater(
        () => dataSource.getLibraries(
          searchTerm: '',
          pageNumber: 1,
          pageSize: 10,
        ),
        throwsA(isA<UnknownException>()),
      );
    });
  });
}
