import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/settings/data/datasources/library_registration_remote_data_source.dart';
import 'package:quraaa/features/settings/data/models/library_registration_model.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  group('LibraryRegistrationRemoteDataSource', () {
    late _MockHttpHelper httpHelper;
    late LibraryRegistrationRemoteDataSource dataSource;

    setUp(() {
      httpHelper = _MockHttpHelper();
      dataSource = LibraryRegistrationRemoteDataSourceImpl(httpHelper);
    });

    test('posts a null body and parses the registration response', () async {
      when(
        () => httpHelper.post(ApiEndpoints.libraryRegistration, data: null),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: ApiEndpoints.libraryRegistration,
          ),
          data: <String, dynamic>{
            'registrationUrl':
                'https://library.quraa.dev/libraries/register#token=test',
            'expiresAtUtc': '2026-08-14T15:59:25.6662797Z',
          },
        ),
      );

      final LibraryRegistrationModel result =
          await dataSource.requestRegistration();

      expect(
        result.registrationUrl,
        'https://library.quraa.dev/libraries/register#token=test',
      );
      expect(
        result.expiresAtUtc,
        DateTime.parse('2026-08-14T15:59:25.6662797Z'),
      );
      verify(
        () => httpHelper.post(ApiEndpoints.libraryRegistration, data: null),
      ).called(1);
    });

    test('rejects a response without a valid web registration URL', () async {
      when(
        () => httpHelper.post(ApiEndpoints.libraryRegistration, data: null),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: ApiEndpoints.libraryRegistration,
          ),
          data: <String, dynamic>{
            'registrationUrl': 'not-a-web-url',
            'expiresAtUtc': '2026-08-14T15:59:25.6662797Z',
          },
        ),
      );

      expect(
        dataSource.requestRegistration,
        throwsA(isA<UnknownException>()),
      );
    });
  });
}
