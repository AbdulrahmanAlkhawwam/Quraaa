import 'error_codes.dart';
import 'error_response_model.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorMapper {
  ErrorMapper._();

  static AppException mapResponseToException(ErrorResponseModel response) {
    final String code =
        response.code ??
        (response.errors.isNotEmpty
            ? ErrorCodes.validationFailed
            : ErrorCodes.unknown);

    return mapCodeToException(
      code,
      title: response.title,
      message: response.message,
    );
  }

  static AppException mapCodeToException(
    String? code, {
    String? title,
    String? message,
    Uri? redirectUri,
    int? statusCode,
  }) {
    switch (code) {
      case ErrorCodes.operationCancelled:
        return OperationCancelledException(message: message);
      case ErrorCodes.operationFailedRetry:
        return OperationFailedException(code: code!, message: message);
      case ErrorCodes.noInternet:
        return NoInternetException(message: message);
      case ErrorCodes.networkErrorRetry:
        return NetworkException(code: code!, message: message);
      case ErrorCodes.timeout:
        return TimeoutException(message: message);
      case ErrorCodes.badRequest:
        return BadRequestException(code: code!, message: message);
      case ErrorCodes.unauthorized:
      case ErrorCodes.wrongPasswordRetry:
      case ErrorCodes.tokenExpired:
      case ErrorCodes.loginFailed:
        return UnauthorizedException(code: code!, message: message);
      case ErrorCodes.forbidden:
        return ForbiddenException(message: message);
      case ErrorCodes.resourceNotFound:
      case ErrorCodes.userNotFound:
      case ErrorCodes.organizationNotFound:
      case ErrorCodes.courseNotFound:
      case ErrorCodes.dataNotFound:
        return NotFoundException(code: code!, message: message);
      case ErrorCodes.validationFailed:
        return ValidationException(code: code!, message: message);
      case ErrorCodes.conflict:
      case ErrorCodes.studentAlreadyExists:
      case ErrorCodes.alreadyEnrolled:
        return ConflictException(code: code!, message: message);
      case ErrorCodes.gone:
        return GoneException(message: message);
      case ErrorCodes.preconditionFailed:
        return PreconditionFailedException(message: message);
      case ErrorCodes.redirection:
        return RedirectionException(
          code: code!,
          redirectUri: redirectUri,
          message: message,
        );
      case ErrorCodes.tooManyRequests:
        return TooManyRequestsException(message: message);
      case ErrorCodes.paymentRequired:
        return PaymentRequiredException(code: code!, message: message);
      case ErrorCodes.subscriptionRequired:
      case ErrorCodes.subscriptionInactive:
      case ErrorCodes.subscriptionExpired:
      case ErrorCodes.subscriptionCancelled:
        return SubscriptionException(code: code!, message: message);
      case ErrorCodes.internalServerError:
        return InternalException(code: code!, message: message);
      case ErrorCodes.serverError:
      case ErrorCodes.serviceUnavailable:
        return ServerException(
          code: code!,
          statusCode: statusCode,
          message: message,
        );
      case ErrorCodes.methodNotAllowed:
        return MethodNotAllowedException(message: message);
      case ErrorCodes.cacheReadFailed:
        return CacheReadException(message: message);
      case ErrorCodes.cacheWriteFailed:
        return CacheWriteException(message: message);
      case ErrorCodes.offlineSyncFailed:
        return OfflineSyncException(message: message);
      case ErrorCodes.downloadFailed:
        return DownloadException(message: message);
      case ErrorCodes.insufficientStorage:
        return InsufficientStorageException(message: message);
      case ErrorCodes.fileAccessDenied:
        return FileAccessDeniedException(message: message);
      default:
        return UnknownException(message: message ?? title);
    }
  }

  static Failure mapExceptionToFailure(AppException exception) {
    switch (exception) {
      case UnknownException _:
        return UnknownFailure(message: exception.message);
      case OperationCancelledException _:
        return OperationCancelledFailure(message: exception.message);
      case OperationFailedException _:
        return OperationFailedFailure(
          code: exception.code,
          message: exception.message,
        );
      case NoInternetException _:
        return NoInternetFailure(message: exception.message);
      case NetworkException _:
        return NetworkFailure(code: exception.code, message: exception.message);
      case TimeoutException _:
        return TimeoutFailure(message: exception.message);
      case BadRequestException _:
        return BadRequestFailure(
          code: exception.code,
          message: exception.message,
        );
      case UnauthorizedException _:
        return UnauthorizedFailure(
          code: exception.code,
          message: exception.message,
        );
      case ForbiddenException _:
        return ForbiddenFailure(message: exception.message);
      case NotFoundException _:
        return NotFoundFailure(
          code: exception.code,
          message: exception.message,
        );
      case ValidationException _:
        return ValidationFailure(
          code: exception.code,
          message: exception.message,
        );
      case ConflictException _:
        return ConflictFailure(
          code: exception.code,
          message: exception.message,
        );
      case GoneException _:
        return GoneFailure(message: exception.message);
      case PreconditionFailedException _:
        return PreconditionFailedFailure(message: exception.message);
      // case RedirectionException:
      //   return RedirectionFailure(
      //     code: exception.code,
      //     redirectUri: exception.redirectUri,
      //     message: exception.message,
      //   );
      case TooManyRequestsException _:
        return TooManyRequestsFailure(message: exception.message);
      case PaymentRequiredException _:
        return PaymentRequiredFailure(
          code: exception.code,
          message: exception.message,
        );
      case SubscriptionException _:
        return SubscriptionFailure(
          code: exception.code,
          message: exception.message,
        );
      case InternalException _:
        return InternalFailure(
          code: exception.code,
          message: exception.message,
        );
      case ServerException _:
        return ServerFailure(
          code: exception.code,
          // statusCode: exception.statusCode,
          message: exception.message,
        );
      case MethodNotAllowedException _:
        return MethodNotAllowedFailure(message: exception.message);
      case CacheReadException _:
        return CacheReadFailure(message: exception.message);
      case CacheWriteException _:
        return CacheWriteFailure(message: exception.message);
      case OfflineSyncException _:
        return OfflineSyncFailure(message: exception.message);
      case DownloadException _:
        return DownloadFailure(message: exception.message);
      case InsufficientStorageException _:
        return InsufficientStorageFailure(message: exception.message);
      case FileAccessDeniedException _:
        return FileAccessDeniedFailure(message: exception.message);
      case LoginFailedException _:
        return LoginFailure(message: exception.message);
      case TokenExpiredException _:
        return TokenExpiredFailure(message: exception.message);
      case UserNotFoundException _:
        return UserNotFoundFailure(message: exception.message);
      case OrganizationNotFoundException _:
        return OrganizationNotFoundFailure(message: exception.message);
      case StudentAlreadyExistsException _:
        return StudentAlreadyExistsFailure(message: exception.message);
      case EnrollmentException _:
        return EnrollmentFailure(message: exception.message);
      case AlreadyEnrolledException _:
        return AlreadyEnrolledFailure(message: exception.message);
      case CourseNotFoundException _:
        return CourseNotFoundFailure(message: exception.message);
      case DataNotFoundException _:
        return DataNotFoundFailure(message: exception.message);
      default:
        return UnknownFailure(message: exception.message);
    }
  }

  static Failure mapResponseToFailure(ErrorResponseModel response) {
    return mapExceptionToFailure(mapResponseToException(response));
  }

  static Failure mapCodeToFailure(
    String? code, {
    String? title,
    String? message,
    Uri? redirectUri,
    int? statusCode,
  }) {
    return mapExceptionToFailure(
      mapCodeToException(
        code,
        title: title,
        message: message,
        redirectUri: redirectUri,
        statusCode: statusCode,
      ),
    );
  }

  static Failure map(Object? error) {
    if (error is Failure) {
      return error;
    }

    if (error is AppException) {
      return mapExceptionToFailure(error);
    }

    if (error is ErrorResponseModel) {
      return mapResponseToFailure(error);
    }

    if (error is Map<String, dynamic>) {
      return mapResponseToFailure(ErrorResponseModel.fromJson(error));
    }

    if (error is String) {
      return mapCodeToFailure(error);
    }

    return const UnknownFailure();
  }
}

Failure mapExceptionToFailure(Object error) {
  return ErrorMapper.map(error);
}

AppException mapResponseToException(ErrorResponseModel response) {
  return ErrorMapper.mapResponseToException(response);
}

Failure mapResponseToFailure(ErrorResponseModel response) {
  return ErrorMapper.mapResponseToFailure(response);
}
