import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/constants/api_endpoints.dart';
import 'package:quraaa/core/errors/error_codes.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/features/auth/data/datasources/auth_remote_datasource.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

void main() {
  group('AuthRemoteDataSource resetPassword', () {
    late _MockHttpHelper httpHelper;
    late AuthRemoteDataSource dataSource;

    setUp(() {
      httpHelper = _MockHttpHelper();
      dataSource = AuthRemoteDataSourceImpl(httpHelper);
    });

    test('maps an empty 401 response to an invalid code exception', () async {
      final RequestOptions request = RequestOptions(
        path: ApiEndpoints.resetPassword,
      );
      when(
        () => httpHelper.post(
          ApiEndpoints.resetPassword,
          data: any<dynamic>(named: 'data'),
        ),
      ).thenThrow(
        DioException.badResponse(
          statusCode: 401,
          requestOptions: request,
          response: Response<dynamic>(requestOptions: request, statusCode: 401),
        ),
      );

      await expectLater(
        dataSource.resetPassword(
          phoneNumber: '+963999111222',
          code: '123456',
          newPassword: 'password1',
        ),
        throwsA(
          isA<UnauthorizedException>()
              .having(
                (UnauthorizedException error) => error.code,
                'code',
                ErrorCodes.invalidVerificationCode,
              )
              .having(
                (UnauthorizedException error) => error.message,
                'message',
                isNot(contains('validateStatus')),
              ),
        ),
      );
    });
  });
}
