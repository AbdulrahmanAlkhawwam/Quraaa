import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../shared/models/message.dart';
import 'error_codes.dart';
import 'failures.dart';

/// Maps any error object to a [Message] suitable for display.
///
/// In **debug** mode the returned message contains the raw technical
/// details (exception type, code, stack trace if available) so
/// developers can diagnose issues quickly.
///
/// In **release** mode the returned message uses the localized
/// friendly strings defined in `assets/translations/{ar,en}.json`
/// under the `errors` namespace.
class ErrorMessageResolver {
  ErrorMessageResolver._();

  /// Resolves an error into a display [Message].
  ///
  /// When [debug] is `true` (the default in debug builds) the raw technical
  /// details are returned. When [debug] is `false` (the default in release
  /// builds) a localized, user-friendly message is returned.
  static Message resolve(Object? error, {bool? debug}) {
    final bool showDebug = debug ?? kDebugMode;
    if (showDebug) {
      return _resolveDebug(error);
    }
    return _resolveRelease(error);
  }

  // -------------------------------------------------------------------------
  // Debug mode – show raw technical details
  // -------------------------------------------------------------------------
  static Message _resolveDebug(Object? error) {
    String title = 'Debug Error';
    String value = error?.toString() ?? 'Unknown error';

    if (error is Failure) {
      title = '${error.runtimeType} (${error.code})';
      value = error.toString();
    }

    return Message(title: title, value: value);
  }

  // -------------------------------------------------------------------------
  // Release mode – show localized user-friendly messages
  // -------------------------------------------------------------------------
  static Message _resolveRelease(Object? error) {
    final String code = _extractCode(error);
    final String translationKey = _mapCodeToTranslationKey(code);

    final String titleKey = 'errors.$translationKey.title';
    final String messageKey = 'errors.$translationKey.message';

    String title = _tryTranslate(titleKey);
    String message = _tryTranslate(messageKey);

    // Fallback to unknown if the specific translation key is missing.
    if (title == titleKey) {
      title = _tryTranslate('errors.unknown.title');
    }
    if (message == messageKey) {
      message = _tryTranslate('errors.unknown.message');
    }

    return Message(title: title, value: message);
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Extracts the error code from a [Failure] or falls back to parsing the
  /// string representation.
  static String _extractCode(Object? error) {
    if (error is Failure) {
      return error.code;
    }

    // Fallback: try to extract `code: X` from the toString() of a Failure.
    final String errorStr = error?.toString() ?? '';
    final RegExp codeRegex = RegExp(r'code:\s*([^,\)]+)');
    final Match? match = codeRegex.firstMatch(errorStr);
    if (match != null) {
      return match.group(1)?.trim() ?? ErrorCodes.unknown;
    }

    return ErrorCodes.unknown;
  }

  /// Safely tries to translate a key; returns the raw key if translation
  /// fails (e.g. the key does not exist in the current locale).
  static String _tryTranslate(String key) {
    try {
      return key.tr();
    } catch (_) {
      return key;
    }
  }

  /// Maps every internal [ErrorCodes] constant to one of the translation keys
  /// that exist in `assets/translations/{ar,en}.json` under `errors`.
  static String _mapCodeToTranslationKey(String code) {
    switch (code) {
      // Network / connectivity
      case ErrorCodes.networkErrorRetry:
        return 'network';
      case ErrorCodes.noInternet:
        return 'no_internet';
      case ErrorCodes.timeout:
        return 'timeout';

      // Auth / permissions
      case ErrorCodes.unauthorized:
      case ErrorCodes.wrongPasswordRetry:
      case ErrorCodes.tokenExpired:
      case ErrorCodes.loginFailed:
        return 'unauthorized';
      case ErrorCodes.forbidden:
        return 'forbidden';

      // Not found
      case ErrorCodes.resourceNotFound:
      case ErrorCodes.userNotFound:
      case ErrorCodes.organizationNotFound:
      case ErrorCodes.courseNotFound:
      case ErrorCodes.dataNotFound:
        return 'not_found';

      // Validation
      case ErrorCodes.validationFailed:
      case ErrorCodes.badRequest:
        return 'validation';

      // Conflict
      case ErrorCodes.conflict:
      case ErrorCodes.studentAlreadyExists:
      case ErrorCodes.alreadyEnrolled:
        return 'conflict';

      // Gone
      case ErrorCodes.gone:
        return 'unknown'; // no dedicated "gone" translation yet

      // Precondition failed
      case ErrorCodes.preconditionFailed:
      case ErrorCodes.methodNotAllowed:
        return 'unknown';

      // Redirection
      case ErrorCodes.redirection:
        return 'redirection';

      // Rate limiting
      case ErrorCodes.tooManyRequests:
        return 'unknown';

      // Payment / subscription
      case ErrorCodes.paymentRequired:
        return 'payment_required';
      case ErrorCodes.subscriptionRequired:
      case ErrorCodes.subscriptionInactive:
      case ErrorCodes.subscriptionExpired:
      case ErrorCodes.subscriptionCancelled:
        return 'subscription';

      // Server errors
      case ErrorCodes.serverError:
      case ErrorCodes.serviceUnavailable:
        return 'server';
      case ErrorCodes.internalServerError:
        return 'internal';

      // Cache / storage / sync / download
      case ErrorCodes.cacheReadFailed:
      case ErrorCodes.cacheWriteFailed:
      case ErrorCodes.offlineSyncFailed:
      case ErrorCodes.downloadFailed:
      case ErrorCodes.insufficientStorage:
      case ErrorCodes.fileAccessDenied:
        return 'unknown';

      // Operation lifecycle
      case ErrorCodes.operationCancelled:
      case ErrorCodes.operationFailedRetry:
        return 'unknown';

      // Enrollment / misc
      case ErrorCodes.enrollmentFailed:
        return 'unknown';

      // Default
      case ErrorCodes.unknown:
      default:
        return 'unknown';
    }
  }
}
