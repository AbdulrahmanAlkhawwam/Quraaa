import 'package:easy_localization/easy_localization.dart';

import '../../../shared/models/message.dart';
import 'error_codes.dart';
import 'error_mapper.dart';
import 'error_response_model.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Maps any error object to a clear, user-facing message.
///
/// The visible title is localized while a useful server-provided reason is
/// preserved. Technical type names and serialized Failure objects are never
/// shown to the user.
class ErrorMessageResolver {
  ErrorMessageResolver._();

  /// Resolves an error into a display [Message].
  ///
  /// [debug] remains for API compatibility; user-facing output is intentionally
  /// readable and consistent in every build mode.
  static Message resolve(Object? error, {bool? debug}) {
    final Failure failure = _toFailure(error);
    final String translationKey = _mapCodeToTranslationKey(failure.code);
    final String title = _translatedOr(
      'errors.$translationKey.title',
      fallback: failure.title,
    );
    final String localizedFallback = _translatedOr(
      'errors.$translationKey.message',
      fallback: ErrorMapper.mapCodeToFailure(failure.code).message,
    );
    final String reason = _formatReason(failure.message);
    final bool useLocalizedFallback = reason.isEmpty ||
        _looksTechnical(reason) ||
        _isDefaultReason(failure.code, reason);

    return Message(
      title: title,
      value: useLocalizedFallback ? localizedFallback : reason,
    );
  }

  static Failure _toFailure(Object? error) {
    if (error is Failure) return error;
    if (error is AppException) {
      return ErrorMapper.mapExceptionToFailure(error);
    }
    if (error is ErrorResponseModel) {
      return ErrorMapper.mapResponseToFailure(error);
    }
    if (error is Map) {
      return ErrorMapper.mapResponseToFailure(
        ErrorResponseModel.fromJson(Map<String, dynamic>.from(error)),
      );
    }
    if (error is String && error.trim().isNotEmpty) {
      return UnknownFailure(message: error.trim());
    }
    return ErrorMapper.map(error);
  }

  static String _translatedOr(String key, {required String fallback}) {
    try {
      final String translated = key.tr();
      return translated == key || translated.trim().isEmpty
          ? fallback
          : translated;
    } catch (_) {
      return fallback;
    }
  }

  static String _formatReason(String value) {
    final Iterable<String> lines = value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .split(RegExp(r'\r?\n'))
        .map(
          (String line) => line
              .replaceFirst(
                RegExp(r'^(exception|error)\s*:\s*', caseSensitive: false),
                '',
              )
              .replaceAll(RegExp(r'[ \t]+'), ' ')
              .trim(),
        )
        .where((String line) => line.isNotEmpty)
        .toSet()
        .take(4);

    final List<String> normalized = lines.toList(growable: false);
    if (normalized.isEmpty) return '';
    final String reason = normalized.length == 1
        ? normalized.first
        : normalized.map((String line) => '• $line').join('\n');
    return reason.length <= 360 ? reason : '${reason.substring(0, 357)}...';
  }

  static bool _looksTechnical(String reason) {
    final String normalized = reason.toLowerCase();
    return normalized.contains('dioexception') ||
        normalized.contains('requestoptions.validatestatus') ||
        normalized.contains('status code of') ||
        normalized.contains('developer.mozilla.org/en-us/docs/web/http/status');
  }

  static bool _isDefaultReason(String code, String reason) {
    return switch (code) {
      ErrorCodes.unknown => reason == 'An unexpected error occurred.',
      ErrorCodes.operationFailedRetry =>
        reason == 'The operation failed. Please try again.',
      ErrorCodes.operationCancelled => reason == 'The operation was cancelled.',
      ErrorCodes.networkErrorRetry =>
        reason == 'A network error occurred. Please try again.',
      ErrorCodes.noInternet => reason == 'No internet connection is available.',
      ErrorCodes.timeout => reason == 'The request timed out.',
      ErrorCodes.badRequest => reason == 'The request was invalid.',
      ErrorCodes.unauthorized ||
      ErrorCodes.wrongPasswordRetry ||
      ErrorCodes.loginFailed =>
        reason == 'Authentication failed.' || reason == 'Login failed.',
      ErrorCodes.invalidVerificationCode =>
        reason == 'The verification code is invalid or expired.',
      ErrorCodes.forbidden =>
        reason == 'You do not have permission to perform this action.',
      ErrorCodes.resourceNotFound ||
      ErrorCodes.userNotFound ||
      ErrorCodes.dataNotFound =>
        reason == 'The requested resource was not found.' ||
            reason == 'The user could not be found.' ||
            reason == 'The requested data could not be found.',
      ErrorCodes.validationFailed =>
        reason == 'Please check the submitted data.',
      ErrorCodes.conflict =>
        reason == 'A conflict occurred while processing the request.',
      ErrorCodes.tooManyRequests =>
        reason == 'Too many requests were sent. Please try again later.',
      ErrorCodes.serverError ||
      ErrorCodes.serviceUnavailable =>
        reason == 'A server error occurred.',
      ErrorCodes.internalServerError =>
        reason == 'An internal server error occurred.',
      ErrorCodes.tokenExpired => reason == 'Your session has expired.',
      _ => false,
    };
  }

  /// Maps every internal [ErrorCodes] constant to one of the translation keys
  /// that exist in `assets/translations/{ar,en}.json` under `errors`.
  static String _mapCodeToTranslationKey(String code) {
    switch (code) {
      case ErrorCodes.networkErrorRetry:
        return 'network';
      case ErrorCodes.noInternet:
        return 'no_internet';
      case ErrorCodes.timeout:
        return 'timeout';

      case ErrorCodes.unauthorized:
        return 'unauthorized';
      case ErrorCodes.wrongPasswordRetry:
        return 'wrong_password';
      case ErrorCodes.invalidVerificationCode:
        return 'invalid_verification_code';
      case ErrorCodes.tokenExpired:
        return 'session_expired';
      case ErrorCodes.loginFailed:
        return 'login_failed';
      case ErrorCodes.forbidden:
        return 'forbidden';

      case ErrorCodes.resourceNotFound:
      case ErrorCodes.userNotFound:
      case ErrorCodes.organizationNotFound:
      case ErrorCodes.courseNotFound:
      case ErrorCodes.dataNotFound:
        return 'not_found';

      case ErrorCodes.validationFailed:
      case ErrorCodes.badRequest:
        return 'validation';

      case ErrorCodes.conflict:
      case ErrorCodes.studentAlreadyExists:
      case ErrorCodes.alreadyEnrolled:
        return 'conflict';

      case ErrorCodes.redirection:
        return 'redirection';
      case ErrorCodes.tooManyRequests:
        return 'too_many_requests';

      case ErrorCodes.paymentRequired:
        return 'payment_required';
      case ErrorCodes.subscriptionRequired:
      case ErrorCodes.subscriptionInactive:
      case ErrorCodes.subscriptionExpired:
      case ErrorCodes.subscriptionCancelled:
        return 'subscription';

      case ErrorCodes.serverError:
      case ErrorCodes.serviceUnavailable:
        return 'server';
      case ErrorCodes.internalServerError:
        return 'internal';

      case ErrorCodes.operationCancelled:
      case ErrorCodes.operationFailedRetry:
        return 'operation_failed';

      case ErrorCodes.gone:
      case ErrorCodes.preconditionFailed:
      case ErrorCodes.methodNotAllowed:
      case ErrorCodes.cacheReadFailed:
      case ErrorCodes.cacheWriteFailed:
      case ErrorCodes.offlineSyncFailed:
      case ErrorCodes.downloadFailed:
      case ErrorCodes.insufficientStorage:
      case ErrorCodes.fileAccessDenied:
      case ErrorCodes.enrollmentFailed:
      case ErrorCodes.unknown:
      default:
        return 'unknown';
    }
  }
}
