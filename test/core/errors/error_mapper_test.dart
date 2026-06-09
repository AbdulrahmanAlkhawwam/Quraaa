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

    test('maps conflict to exception and failure', () {
      _expectMapping(
        code: ErrorCodes.conflict,
        exceptionMatcher: isA<ConflictException>(),
        failureMatcher: isA<ConflictFailure>(),
      );
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
