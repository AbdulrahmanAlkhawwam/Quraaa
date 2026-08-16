import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/sell_book/data/datasources/sell_book_remote_data_source.dart';
import 'package:quraaa/features/sell_book/domain/entities/sell_book.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  setUpAll(() {
    registerFallbackValue(Options());
  });

  test('publishes the raw ISBN and exactly one image as multipart data',
      () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'quraaa-sell-book-test-',
    );
    final File image = File(
      '${directory.path}${Platform.pathSeparator}book.jpg',
    );
    await image.writeAsBytes(<int>[1, 2, 3]);

    final _MockHttpHelper httpHelper = _MockHttpHelper();
    final SellBookRemoteDataSource dataSource =
        SellBookRemoteDataSourceImpl(httpHelper);

    when(
      () => httpHelper.post(
        ApiEndpoints.userPhysicalListings,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: <String, dynamic>{'id': 'listing-id'},
        statusCode: 201,
        requestOptions: RequestOptions(),
      ),
    );

    final String result = await dataSource.submitPhysicalBook(
      SellBookDraft(
        method: SellBookMethod.isbn,
        isbn: '978-0-306-40615-7',
        price: 17.5,
        condition: SellBookCondition.used,
        images: <SellBookImage>[
          SellBookImage(
            path: image.path,
            name: 'book.jpg',
            bytes: 3,
          ),
        ],
      ),
    );

    final VerificationResult verification = verify(
      () => httpHelper.post(
        ApiEndpoints.userPhysicalListings,
        data: captureAny(named: 'data'),
        options: any(named: 'options'),
      ),
    );
    final FormData formData = verification.captured.single as FormData;
    final Map<String, String> fields = <String, String>{
      for (final MapEntry<String, String> field in formData.fields)
        field.key: field.value,
    };

    expect(result, 'listing-id');
    expect(fields['Isbn'], '978-0-306-40615-7');
    expect(fields['Price'], '17.5');
    expect(fields['Condition'], '3');
    expect(formData.files, hasLength(1));
    expect(formData.files.single.key, 'CoverImage');

    await directory.delete(recursive: true);
  });

  test('maps a 404 response to a clear ISBN not-found error', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'quraaa-sell-book-not-found-test-',
    );
    final File image = File(
      '${directory.path}${Platform.pathSeparator}book.jpg',
    );
    await image.writeAsBytes(<int>[1, 2, 3]);

    final _MockHttpHelper httpHelper = _MockHttpHelper();
    final SellBookRemoteDataSource dataSource =
        SellBookRemoteDataSourceImpl(httpHelper);
    final RequestOptions request = RequestOptions(
      path: ApiEndpoints.userPhysicalListings,
    );

    when(
      () => httpHelper.post(
        ApiEndpoints.userPhysicalListings,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: request,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: 404,
          data: <String, dynamic>{
            'type': 'NotFound',
            'title': 'Resource Not Found',
            'detail': 'Requested resource was not found.',
          },
        ),
      ),
    );

    await expectLater(
      dataSource.submitPhysicalBook(
        SellBookDraft(
          method: SellBookMethod.isbn,
          isbn: 'unknown-isbn',
          price: 17.5,
          condition: SellBookCondition.used,
          images: <SellBookImage>[
            SellBookImage(
              path: image.path,
              name: 'book.jpg',
              bytes: 3,
            ),
          ],
        ),
      ),
      throwsA(
        isA<NotFoundException>().having(
          (NotFoundException error) => error.message,
          'message',
          'No published book was found for the entered ISBN.',
        ),
      ),
    );

    await directory.delete(recursive: true);
  });
}
