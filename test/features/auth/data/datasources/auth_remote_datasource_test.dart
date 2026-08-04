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
  group('AuthRemoteDataSource registration', () {
    late _MockHttpHelper httpHelper;
    late AuthRemoteDataSource dataSource;

    setUp(() {
      httpHelper = _MockHttpHelper();
      dataSource = AuthRemoteDataSourceImpl(httpHelper);
    });

    test('maps a pending unverified account to OTP required', () async {
      final RequestOptions request = RequestOptions(
        path: ApiEndpoints.register,
      );
      when(
        () => httpHelper.post(
          ApiEndpoints.register,
          data: any<dynamic>(named: 'data'),
        ),
      ).thenThrow(
        DioException.badResponse(
          statusCode: 400,
          requestOptions: request,
          response: Response<dynamic>(
            requestOptions: request,
            statusCode: 400,
            data: <String, dynamic>{
              'type': 'phone_number_not_verified',
              'title': 'Verification required',
              'detail':
                  'The account already exists and is pending OTP verification.',
            },
          ),
        ),
      );

      await expectLater(
        dataSource.register(phoneNumber: '+963999111222'),
        throwsA(isA<OtpVerificationRequiredException>()),
      );
    });

    test(
      'keeps an ordinary validation response as validation failure',
      () async {
        final RequestOptions request = RequestOptions(
          path: ApiEndpoints.register,
        );
        when(
          () => httpHelper.post(
            ApiEndpoints.register,
            data: any<dynamic>(named: 'data'),
          ),
        ).thenThrow(
          DioException.badResponse(
            statusCode: 400,
            requestOptions: request,
            response: Response<dynamic>(
              requestOptions: request,
              statusCode: 400,
              data: <String, dynamic>{
                'type': 'ValidationFailure',
                'errors': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'field': 'FirstName',
                    'message': 'First name is required.',
                  },
                ],
              },
            ),
          ),
        );

        await expectLater(
          dataSource.register(phoneNumber: '+963999111222'),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });

  group('AuthRemoteDataSource password recovery', () {
    late _MockHttpHelper httpHelper;
    late AuthRemoteDataSource dataSource;

    setUp(() {
      httpHelper = _MockHttpHelper();
      dataSource = AuthRemoteDataSourceImpl(httpHelper);
    });

    test('sends the phone number to forgot-password', () async {
      final RequestOptions request = RequestOptions(
        path: ApiEndpoints.forgotPassword,
      );
      when(
        () => httpHelper.post(
          ApiEndpoints.forgotPassword,
          data: <String, Object?>{'phoneNumber': '+963999111222'},
        ),
      ).thenAnswer(
        (_) async =>
            Response<dynamic>(requestOptions: request, statusCode: 200),
      );

      await dataSource.forgotPassword(phoneNumber: '+963999111222');

      verify(
        () => httpHelper.post(
          ApiEndpoints.forgotPassword,
          data: <String, Object?>{'phoneNumber': '+963999111222'},
        ),
      ).called(1);
    });

    test('sends otpCode and newPassword to forgot-password/verify', () async {
      final RequestOptions request = RequestOptions(
        path: ApiEndpoints.forgotPasswordVerify,
      );
      when(
        () => httpHelper.post(
          ApiEndpoints.forgotPasswordVerify,
          data: <String, Object?>{
            'phoneNumber': '+963999111222',
            'otpCode': '123456',
            'newPassword': 'password1',
          },
        ),
      ).thenAnswer(
        (_) async =>
            Response<dynamic>(requestOptions: request, statusCode: 200),
      );

      await dataSource.resetPassword(
        phoneNumber: '+963999111222',
        code: '123456',
        newPassword: 'password1',
      );

      verify(
        () => httpHelper.post(
          ApiEndpoints.forgotPasswordVerify,
          data: <String, Object?>{
            'phoneNumber': '+963999111222',
            'otpCode': '123456',
            'newPassword': 'password1',
          },
        ),
      ).called(1);
    });

    test('maps an empty 401 response to an invalid code exception', () async {
      final RequestOptions request = RequestOptions(
        path: ApiEndpoints.forgotPasswordVerify,
      );
      when(
        () => httpHelper.post(
          ApiEndpoints.forgotPasswordVerify,
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
