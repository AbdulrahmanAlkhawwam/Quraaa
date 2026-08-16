import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/libraries/data/datasources/authors_remote_data_source.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  late _MockHttpHelper http;
  late AuthorsRemoteDataSource dataSource;

  setUp(() {
    http = _MockHttpHelper();
    dataSource = AuthorsRemoteDataSourceImpl(http);
  });

  test('loads an author by id', () async {
    when(() => http.get(ApiEndpoints.author('author-1'))).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'id': 'author-1',
          'name': 'Naguib Mahfouz',
          'bio': 'Bio',
          'photoUrl': null,
          'birthDate': '1911-12-11T00:00:00Z',
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final author = await dataSource.getAuthor('author-1');

    expect(author.id, 'author-1');
    expect(author.name, 'Naguib Mahfouz');
  });

  test('loads author books and searches authors with documented queries',
      () async {
    when(
      () => http.get(
        ApiEndpoints.authorBooks('author-1'),
        queryParameters: <String, dynamic>{
          'PageNumber': 1,
          'PageSize': 20,
        },
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'listingId': 'listing-1',
              'title': 'Book',
              'authorName': 'Author',
              'coverImageUrl': '',
              'category': null,
              'format': 'EBook',
              'startingPrice': 3,
              'isFree': false,
              'sellersCount': 1,
              'averageRating': 4.5,
              'ratingsCount': 2,
            },
          ],
          'hasNextPage': false,
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );
    when(
      () => http.get(
        ApiEndpoints.authorSearch,
        queryParameters: <String, dynamic>{
          'SearchTerm': 'Author',
          'PageNumber': 1,
          'PageSize': 10,
        },
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'author-1',
              'name': 'Author',
              'photoUrl': null,
              'totalBooksCount': 1,
            },
          ],
          'totalCount': 1,
          'hasNextPage': false,
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final books = await dataSource.getAuthorBooks(
      'author-1',
      pageNumber: 1,
      pageSize: 20,
    );
    final authors = await dataSource.searchAuthors(
      'Author',
      pageNumber: 1,
      pageSize: 10,
    );

    expect(books.items.single.listingId, 'listing-1');
    expect(authors.items.single.id, 'author-1');
  });
}
