import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/errors/error_codes.dart';
import 'package:quraaa/core/errors/error_mapper.dart';
import 'package:quraaa/core/errors/error_response_model.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';

void main() {
  group('ErrorMapper', () {
    test('maps unknown error to exception and failure', () {
      _expectMapping(
        code: ErrorCodes.unknown,
        exceptionMatcher: isA<UnknownException>(),
        failureMatcher: isA<UnknownFailure>(),
      );
    });

    test('maps network error to exception and failure', () {
      _expectMapping(
        code: ErrorCodes.networkErrorRetry,
        exceptionMatcher: isA<NetworkException>(),
        failureMatcher: isA<NetworkFailure>(),
      );
    });

    test('maps resource not found to exception and failure', () {
      _expectMapping(
        code: ErrorCodes.resourceNotFound,
        exceptionMatcher: isA<NotFoundException>(),
        failureMatcher: isA<NotFoundFailure>(),
      );
    });

    test('maps wrong password retry to exception and failure', () {
      _expectMapping(
        code: ErrorCodes.wrongPasswordRetry,
        exceptionMatcher: isA<UnauthorizedException>(),
        failureMatcher: isA<UnauthorizedFailure>(),
      );
    });

    test('maps payment required to exception and failure', () {
      _expectMapping(
        code: ErrorCodes.paymentRequired,
        exceptionMatcher: isA<PaymentRequiredException>(),
        failureMatcher: isA<PaymentRequiredFailure>(),
      );
    });

    test('maps OTP verification required to its typed failure', () {
      _expectMapping(
        code: ErrorCodes.otpVerificationRequired,
        exceptionMatcher: isA<OtpVerificationRequiredException>(),
        failureMatcher: isA<OtpVerificationRequiredFailure>(),
      );
    });

    test('maps conflict to exception and failure', () {
      _expectMapping(
        code: ErrorCodes.conflict,
        exceptionMatcher: isA<ConflictException>(),
        failureMatcher: isA<ConflictFailure>(),
      );
    });

    test('maps a top-level API message using the HTTP status', () {
      final ErrorResponseModel response = ErrorResponseModel.fromJson(
        <String, dynamic>{'message': 'The credentials are incorrect.'},
        statusCode: 401,
      );

      final Failure failure = ErrorMapper.mapResponseToFailure(response);

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.code, ErrorCodes.unauthorized);
      expect(failure.message, 'The credentials are incorrect.');
    });

    test('reads validation messages from the backend errors array', () {
      final ErrorResponseModel response = ErrorResponseModel.fromJson(
        <String, dynamic>{
          'type': 'ValidationFailure',
          'title': 'Validation Error',
          'errors': <Map<String, dynamic>>[
            <String, dynamic>{
              'field': 'PhoneNumber',
              'message': 'Invalid international phone number format.',
            },
          ],
        },
        statusCode: 400,
      );

      final Failure failure = ErrorMapper.mapResponseToFailure(response);

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Invalid international phone number format.');
    });

    test('uses detail from a problem-details response', () {
      final ErrorResponseModel response =
          ErrorResponseModel.fromJson(<String, dynamic>{
            'type': 'invalid-otp',
            'title': 'Invalid OTP',
            'status': 400,
            'detail': 'The verification code is invalid or expired.',
            'instance': '/api/auth/forgot-password/verify',
          });

      final Failure failure = ErrorMapper.mapResponseToFailure(response);

      expect(failure, isA<BadRequestFailure>());
      expect(failure.message, 'The verification code is invalid or expired.');
    });

    test('combines validation messages instead of hiding the reason', () {
      final ErrorResponseModel response = ErrorResponseModel.fromJson(
        <String, dynamic>{
          'status': 422,
          'errors': <String, dynamic>{
            'phoneNumber': <String>['Phone number is invalid.'],
            'password': <String>['Password is too short.'],
          },
        },
      );

      final Failure failure = ErrorMapper.mapResponseToFailure(response);

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('Phone number is invalid.'));
      expect(failure.message, contains('Password is too short.'));
    });
  });
}

void _expectMapping({
  required String code,
  required Matcher exceptionMatcher,
  required Matcher failureMatcher,
}) {
  final ErrorResponseModel response = ErrorResponseModel.fromJson(
    <String, dynamic>{
      'error': <String, dynamic>{
        'code': code,
        'title': 'Server title',
        'message': 'Server message',
      },
    },
  );

  final AppException exception = ErrorMapper.mapResponseToException(response);
  expect(exception, exceptionMatcher);
  expect(exception.code, code);
  expect(exception.message, 'Server message');

  final Failure failure = ErrorMapper.mapExceptionToFailure(exception);
  expect(failure, failureMatcher);
  expect(failure.code, code);
  expect(failure.message, 'Server message');
}
