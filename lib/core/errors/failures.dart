import 'package:equatable/equatable.dart';

import 'error_codes.dart';

abstract class Failure extends Equatable {
  const Failure({
    required this.code,
    required this.title,
    required this.message,
  });

  final String code;
  final String title;
  final String message;

  @override
  List<Object?> get props => <Object?>[code, title, message];

  @override
  String toString() =>
      '$runtimeType(code: $code, title: $title, message: $message)';
}

class _BaseFailure extends Failure {
  const _BaseFailure({
    required super.code,
    required super.title,
    required super.message,
  });
}

final class UnknownFailure extends _BaseFailure {
  const UnknownFailure({String? message})
    : super(
        code: ErrorCodes.unknown,
        title: 'Unknown Error',
        message: message ?? 'An unexpected error occurred.',
      );
}

final class OperationFailedFailure extends _BaseFailure {
  const OperationFailedFailure({
    super.code = ErrorCodes.operationFailedRetry, String? message,
  }) : super(
         title: 'Operation Failed',
         message: message ?? 'The operation failed. Please try again.',
       );
}

final class OperationCancelledFailure extends _BaseFailure {
  const OperationCancelledFailure({String? message})
    : super(
        code: ErrorCodes.operationCancelled,
        title: 'Operation Cancelled',
        message: message ?? 'The operation was cancelled.',
      );
}

final class NetworkFailure extends _BaseFailure {
  const NetworkFailure({
    super.code = ErrorCodes.networkErrorRetry, String? message,
  }) : super(
         title: 'Network Error',
         message: message ?? 'A network error occurred. Please try again.',
       );
}

final class NoInternetFailure extends _BaseFailure {
  const NoInternetFailure({String? message})
    : super(
        code: ErrorCodes.noInternet,
        title: 'No Internet Connection',
        message: message ?? 'No internet connection is available.',
      );
}

final class TimeoutFailure extends _BaseFailure {
  const TimeoutFailure({String? message})
    : super(
        code: ErrorCodes.timeout,
        title: 'Timeout',
        message: message ?? 'The request timed out.',
      );
}

final class BadRequestFailure extends _BaseFailure {
  const BadRequestFailure({super.code = ErrorCodes.badRequest, String? message})
    : super(
        title: 'Bad Request',
        message: message ?? 'The request was invalid.',
      );
}

final class UnauthorizedFailure extends _BaseFailure {
  const UnauthorizedFailure({
    super.code = ErrorCodes.unauthorized, String? message,
  }) : super(
         title: 'Unauthorized',
         message: message ?? 'Authentication failed.',
       );
}

final class ForbiddenFailure extends _BaseFailure {
  const ForbiddenFailure({String? message})
    : super(
        code: ErrorCodes.forbidden,
        title: 'Forbidden',
        message:
            message ?? 'You do not have permission to perform this action.',
      );
}

final class NotFoundFailure extends _BaseFailure {
  const NotFoundFailure({
    super.code = ErrorCodes.resourceNotFound, String? message,
  }) : super(
         title: 'Not Found',
         message: message ?? 'The requested resource was not found.',
       );
}

final class ValidationFailure extends _BaseFailure {
  const ValidationFailure({
    super.code = ErrorCodes.validationFailed, String? message,
  }) : super(
         title: 'Validation Error',
         message: message ?? 'Please check the submitted data.',
       );
}

final class ConflictFailure extends _BaseFailure {
  const ConflictFailure({super.code = ErrorCodes.conflict, String? message})
    : super(
        title: 'Conflict',
        message: message ?? 'A conflict occurred while processing the request.',
      );
}

final class GoneFailure extends _BaseFailure {
  const GoneFailure({String? message})
    : super(
        code: ErrorCodes.gone,
        title: 'Gone',
        message: message ?? 'The requested resource is no longer available.',
      );
}

final class PreconditionFailedFailure extends _BaseFailure {
  const PreconditionFailedFailure({String? message})
    : super(
        code: ErrorCodes.preconditionFailed,
        title: 'Precondition Failed',
        message: message ?? 'A precondition for the request was not met.',
      );
}

final class RedirectionFailure extends _BaseFailure {
  const RedirectionFailure({
    super.code = ErrorCodes.redirection,
    this.redirectUri,
    String? message,
  }) : super(
         title: 'Redirection',
          message: message ?? 'The request requires redirection.',
        );

  final Uri? redirectUri;

  @override
  List<Object?> get props => <Object?>[...super.props, redirectUri];
}

final class TooManyRequestsFailure extends _BaseFailure {
  const TooManyRequestsFailure({String? message})
    : super(
        code: ErrorCodes.tooManyRequests,
        title: 'Too Many Requests',
        message:
            message ?? 'Too many requests were sent. Please try again later.',
      );
}

final class PaymentRequiredFailure extends _BaseFailure {
  const PaymentRequiredFailure({
    super.code = ErrorCodes.paymentRequired, String? message,
  }) : super(
         title: 'Payment Required',
         message: message ?? 'A payment is required to continue.',
       );
}

final class SubscriptionFailure extends _BaseFailure {
  const SubscriptionFailure({
    super.code = ErrorCodes.subscriptionRequired,
    String? message,
  }) : super(
         title: 'Subscription Error',
          message: message ?? 'Your subscription does not allow this action.',
        );
}

final class InternalFailure extends _BaseFailure {
  const InternalFailure({
    super.code = ErrorCodes.internalServerError, String? message,
  }) : super(
         title: 'Internal Error',
         message: message ?? 'An internal server error occurred.',
       );
}

final class ServerFailure extends _BaseFailure {
  const ServerFailure({
    super.code = ErrorCodes.serverError,
    this.statusCode,
    String? message,
  }) : super(
         title: 'Server Error',
          message: message ?? 'A server error occurred.',
        );

  final int? statusCode;

  @override
  List<Object?> get props => <Object?>[...super.props, statusCode];
}

final class MethodNotAllowedFailure extends _BaseFailure {
  const MethodNotAllowedFailure({String? message})
    : super(
        code: ErrorCodes.methodNotAllowed,
        title: 'Method Not Allowed',
        message: message ?? 'The request method is not allowed.',
      );
}

final class CacheReadFailure extends _BaseFailure {
  const CacheReadFailure({String? message})
    : super(
        code: ErrorCodes.cacheReadFailed,
        title: 'Cache Read Error',
        message: message ?? 'Unable to read cached data.',
      );
}

final class CacheWriteFailure extends _BaseFailure {
  const CacheWriteFailure({String? message})
    : super(
        code: ErrorCodes.cacheWriteFailed,
        title: 'Cache Write Error',
        message: message ?? 'Unable to save cached data.',
      );
}

final class OfflineSyncFailure extends _BaseFailure {
  const OfflineSyncFailure({String? message})
    : super(
        code: ErrorCodes.offlineSyncFailed,
        title: 'Offline Sync Error',
        message: message ?? 'Unable to synchronize while offline.',
      );
}

final class DownloadFailure extends _BaseFailure {
  const DownloadFailure({String? message})
    : super(
        code: ErrorCodes.downloadFailed,
        title: 'Download Error',
        message: message ?? 'The download failed.',
      );
}

final class InsufficientStorageFailure extends _BaseFailure {
  const InsufficientStorageFailure({String? message})
    : super(
        code: ErrorCodes.insufficientStorage,
        title: 'Insufficient Storage',
        message: message ?? 'There is not enough storage available.',
      );
}

final class FileAccessDeniedFailure extends _BaseFailure {
  const FileAccessDeniedFailure({String? message})
    : super(
        code: ErrorCodes.fileAccessDenied,
        title: 'File Access Denied',
        message: message ?? 'File access was denied.',
      );
}

final class LoginFailure extends _BaseFailure {
  const LoginFailure({String? message})
    : super(
        code: ErrorCodes.loginFailed,
        title: 'Login Failed',
        message: message ?? 'Login failed.',
      );
}

final class TokenExpiredFailure extends _BaseFailure {
  const TokenExpiredFailure({String? message})
    : super(
        code: ErrorCodes.tokenExpired,
        title: 'Token Expired',
        message: message ?? 'Your session has expired.',
      );
}

final class UserNotFoundFailure extends _BaseFailure {
  const UserNotFoundFailure({String? message})
    : super(
        code: ErrorCodes.userNotFound,
        title: 'User Not Found',
        message: message ?? 'The user could not be found.',
      );
}

final class OrganizationNotFoundFailure extends _BaseFailure {
  const OrganizationNotFoundFailure({String? message})
    : super(
        code: ErrorCodes.organizationNotFound,
        title: 'Organization Not Found',
        message: message ?? 'The organization could not be found.',
      );
}

final class StudentAlreadyExistsFailure extends _BaseFailure {
  const StudentAlreadyExistsFailure({String? message})
    : super(
        code: ErrorCodes.studentAlreadyExists,
        title: 'Student Already Exists',
        message: message ?? 'The student already exists.',
      );
}

final class EnrollmentFailure extends _BaseFailure {
  const EnrollmentFailure({String? message})
    : super(
        code: ErrorCodes.enrollmentFailed,
        title: 'Enrollment Failed',
        message: message ?? 'The enrollment operation failed.',
      );
}

final class AlreadyEnrolledFailure extends _BaseFailure {
  const AlreadyEnrolledFailure({String? message})
    : super(
        code: ErrorCodes.alreadyEnrolled,
        title: 'Already Enrolled',
        message: message ?? 'The user is already enrolled.',
      );
}

final class CourseNotFoundFailure extends _BaseFailure {
  const CourseNotFoundFailure({String? message})
    : super(
        code: ErrorCodes.courseNotFound,
        title: 'Course Not Found',
        message: message ?? 'The course could not be found.',
      );
}

final class DataNotFoundFailure extends _BaseFailure {
  const DataNotFoundFailure({String? message})
    : super(
        code: ErrorCodes.dataNotFound,
        title: 'Data Not Found',
        message: message ?? 'The requested data could not be found.',
      );
}
