import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/book_assistant/data/datasources/book_assistant_remote_data_source.dart';
import 'package:quraaa/features/book_assistant/data/models/book_summary_model.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  group('BookAssistantRemoteDataSource', () {
    late _MockHttpHelper httpHelper;
    late BookAssistantRemoteDataSource dataSource;

    setUp(() {
      httpHelper = _MockHttpHelper();
      dataSource = BookAssistantRemoteDataSourceImpl(httpHelper);
    });

    test('posts purchaseId and parses summary', () async {
      when(
        () => httpHelper.post(
          ApiEndpoints.aiSummarize,
          data: any<Object?>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ApiEndpoints.aiSummarize),
          data: <String, dynamic>{'summary': 'The important points.'},
        ),
      );

      final BookSummaryModel result = await dataSource.summarize(
        purchaseId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      );

      expect(result.summary, 'The important points.');
      final Object? requestBody = verify(
        () => httpHelper.post(
          ApiEndpoints.aiSummarize,
          data: captureAny<Object?>(named: 'data'),
        ),
      ).captured.single;
      expect(
        requestBody,
        <String, Object?>{
          'purchaseId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        },
      );
    });

    test('rejects an empty summary response', () async {
      when(
        () => httpHelper.post(
          ApiEndpoints.aiSummarize,
          data: any<Object?>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ApiEndpoints.aiSummarize),
          data: <String, dynamic>{'summary': ''},
        ),
      );

      expect(
        () => dataSource.summarize(purchaseId: 'purchase-1'),
        throwsA(isA<UnknownException>()),
      );
    });

    test('posts the current page to the translate endpoint', () async {
      when(
        () => httpHelper.post(
          ApiEndpoints.aiTranslate,
          data: any<Object?>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ApiEndpoints.aiTranslate),
          data: <String, dynamic>{'translatedText': 'Translated page.'},
        ),
      );

      final String result = await dataSource.translate(
        purchaseId: 'purchase-1',
        pageNumber: 7,
        targetLanguage: 'Arabic',
      );

      expect(result, 'Translated page.');
      final Object? requestBody = verify(
        () => httpHelper.post(
          ApiEndpoints.aiTranslate,
          data: captureAny<Object?>(named: 'data'),
        ),
      ).captured.single;
      expect(requestBody, <String, Object?>{
        'purchaseId': 'purchase-1',
        'pageNumber': 7,
        'targetLanguage': 'Arabic',
      });
    });
  });
}
