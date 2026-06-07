import 'error_codes.dart';

abstract class AppException implements Exception {
  const AppException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class _BaseException extends AppException {
  const _BaseException({required super.code, required super.message});
}

final class UnknownException extends _BaseException {
  const UnknownException({String? message})
    : super(
        code: ErrorCodes.unknown,
        message: message ?? 'An unexpected error occurred.',
      );
}

final class OperationFailedException extends _BaseException {
  const OperationFailedException({
    String code = ErrorCodes.operationFailedRetry,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'The operation failed. Please try again.',
       );
}

final class OperationCancelledException extends _BaseException {
  const OperationCancelledException({String? message})
    : super(
        code: ErrorCodes.operationCancelled,
        message: message ?? 'The operation was cancelled.',
      );
}

final class NetworkException extends _BaseException {
  const NetworkException({
    String code = ErrorCodes.networkErrorRetry,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'A network error occurred. Please try again.',
       );
}

final class NoInternetException extends _BaseException {
  const NoInternetException({String? message})
    : super(
        code: ErrorCodes.noInternet,
        message: message ?? 'No internet connection is available.',
      );
}

final class TimeoutException extends _BaseException {
  const TimeoutException({String? message})
    : super(
        code: ErrorCodes.timeout,
        message: message ?? 'The request timed out.',
      );
}

final class BadRequestException extends _BaseException {
  const BadRequestException({
    String code = ErrorCodes.badRequest,
    String? message,
  }) : super(code: code, message: message ?? 'The request was invalid.');
}

final class UnauthorizedException extends _BaseException {
  const UnauthorizedException({
    String code = ErrorCodes.unauthorized,
    String? message,
  }) : super(code: code, message: message ?? 'Authentication failed.');
}

final class ForbiddenException extends _BaseException {
  const ForbiddenException({String? message})
    : super(
        code: ErrorCodes.forbidden,
        message:
            message ?? 'You do not have permission to perform this action.',
      );
}

final class NotFoundException extends _BaseException {
  const NotFoundException({
    String code = ErrorCodes.resourceNotFound,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'The requested resource was not found.',
       );
}

final class ValidationException extends _BaseException {
  const ValidationException({
    String code = ErrorCodes.validationFailed,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'Please check the submitted data.',
       );
}

final class ConflictException extends _BaseException {
  const ConflictException({String code = ErrorCodes.conflict, String? message})
    : super(
        code: code,
        message: message ?? 'A conflict occurred while processing the request.',
      );
}

final class GoneException extends _BaseException {
  const GoneException({String? message})
    : super(
        code: ErrorCodes.gone,
        message: message ?? 'The requested resource is no longer available.',
      );
}

final class PreconditionFailedException extends _BaseException {
  const PreconditionFailedException({String? message})
    : super(
        code: ErrorCodes.preconditionFailed,
        message: message ?? 'A precondition for the request was not met.',
      );
}

final class RedirectionException extends _BaseException {
  const RedirectionException({
    String code = ErrorCodes.redirection,
    this.redirectUri,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'The request requires redirection.',
       );

  final Uri? redirectUri;
}

final class TooManyRequestsException extends _BaseException {
  const TooManyRequestsException({String? message})
    : super(
        code: ErrorCodes.tooManyRequests,
        message:
            message ?? 'Too many requests were sent. Please try again later.',
      );
}

final class PaymentRequiredException extends _BaseException {
  const PaymentRequiredException({
    String code = ErrorCodes.paymentRequired,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'A payment is required to continue.',
       );
}

final class SubscriptionException extends _BaseException {
  const SubscriptionException({
    String code = ErrorCodes.subscriptionRequired,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'Your subscription does not allow this action.',
       );
}

final class InternalException extends _BaseException {
  const InternalException({
    String code = ErrorCodes.internalServerError,
    String? message,
  }) : super(
         code: code,
         message: message ?? 'An internal server error occurred.',
       );
}

final class ServerException extends _BaseException {
  const ServerException({
    String code = ErrorCodes.serverError,
    this.statusCode,
    String? message,
  }) : super(code: code, message: message ?? 'A server error occurred.');

  final int? statusCode;
}

final class MethodNotAllowedException extends _BaseException {
  const MethodNotAllowedException({String? message})
    : super(
        code: ErrorCodes.methodNotAllowed,
        message: message ?? 'The request method is not allowed.',
      );
}

final class CacheReadException extends _BaseException {
  const CacheReadException({String? message})
    : super(
        code: ErrorCodes.cacheReadFailed,
        message: message ?? 'Unable to read cached data.',
      );
}

final class CacheWriteException extends _BaseException {
  const CacheWriteException({String? message})
    : super(
        code: ErrorCodes.cacheWriteFailed,
        message: message ?? 'Unable to save cached data.',
      );
}

final class OfflineSyncException extends _BaseException {
  const OfflineSyncException({String? message})
    : super(
        code: ErrorCodes.offlineSyncFailed,
        message: message ?? 'Unable to synchronize while offline.',
      );
}

final class DownloadException extends _BaseException {
  const DownloadException({String? message})
    : super(
        code: ErrorCodes.downloadFailed,
        message: message ?? 'The download failed.',
      );
}

final class InsufficientStorageException extends _BaseException {
  const InsufficientStorageException({String? message})
    : super(
        code: ErrorCodes.insufficientStorage,
        message: message ?? 'There is not enough storage available.',
      );
}

final class FileAccessDeniedException extends _BaseException {
  const FileAccessDeniedException({String? message})
    : super(
        code: ErrorCodes.fileAccessDenied,
        message: message ?? 'File access was denied.',
      );
}

final class LoginFailedException extends _BaseException {
  const LoginFailedException({String? message})
    : super(code: ErrorCodes.loginFailed, message: message ?? 'Login failed.');
}

final class TokenExpiredException extends _BaseException {
  const TokenExpiredException({String? message})
    : super(
        code: ErrorCodes.tokenExpired,
        message: message ?? 'Your session has expired.',
      );
}

final class UserNotFoundException extends _BaseException {
  const UserNotFoundException({String? message})
    : super(
        code: ErrorCodes.userNotFound,
        message: message ?? 'The user could not be found.',
      );
}

final class OrganizationNotFoundException extends _BaseException {
  const OrganizationNotFoundException({String? message})
    : super(
        code: ErrorCodes.organizationNotFound,
        message: message ?? 'The organization could not be found.',
      );
}

final class StudentAlreadyExistsException extends _BaseException {
  const StudentAlreadyExistsException({String? message})
    : super(
        code: ErrorCodes.studentAlreadyExists,
        message: message ?? 'The student already exists.',
      );
}

final class EnrollmentException extends _BaseException {
  const EnrollmentException({String? message})
    : super(
        code: ErrorCodes.enrollmentFailed,
        message: message ?? 'The enrollment operation failed.',
      );
}

final class AlreadyEnrolledException extends _BaseException {
  const AlreadyEnrolledException({String? message})
    : super(
        code: ErrorCodes.alreadyEnrolled,
        message: message ?? 'The user is already enrolled.',
      );
}

final class CourseNotFoundException extends _BaseException {
  const CourseNotFoundException({String? message})
    : super(
        code: ErrorCodes.courseNotFound,
        message: message ?? 'The course could not be found.',
      );
}

final class DataNotFoundException extends _BaseException {
  const DataNotFoundException({String? message})
    : super(
        code: ErrorCodes.dataNotFound,
        message: message ?? 'The requested data could not be found.',
      );
}
