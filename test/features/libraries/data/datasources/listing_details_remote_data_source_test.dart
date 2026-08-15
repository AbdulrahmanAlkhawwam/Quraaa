import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/libraries/data/datasources/library_details_remote_data_source.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  test('requests listing details with the listing ID', () async {
    const String listingId = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
    final _MockHttpHelper httpHelper = _MockHttpHelper();
    final LibraryDetailsRemoteDataSource dataSource =
        LibraryDetailsRemoteDataSourceImpl(httpHelper);

    when(
      () => httpHelper.get(ApiEndpoints.listingDetails(listingId)),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{
          'listingId': listingId,
          'price': '12.8',
          'stock': 2,
          'condition': 'New',
          'format': 'Digital',
          'version': '2025',
          'book': <String, dynamic>{
            'bookId': 'book-id',
            'title': 'Global English',
            'author': 'Tim Carter',
            'description': '',
            'coverImageUrl': '',
            'language': 'English',
            'isbn': '',
            'category': <String, dynamic>{},
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final result = await dataSource.getListingDetails(listingId);

    expect(result.listingId, listingId);
    expect(result.title, 'Global English');
    verify(
      () => httpHelper.get(ApiEndpoints.listingDetails(listingId)),
    ).called(1);
  });
}
