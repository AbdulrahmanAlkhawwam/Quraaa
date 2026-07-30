import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/errors/error_codes.dart';
import 'package:quraaa/core/errors/error_message_resolver.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/shared/models/message.dart';

void main() {
  setUpAll(() {
    // Silence Easy Localization warnings in unit tests where assets are not
    // loaded through the widget tree.
    EasyLocalization.logger.enableLevels = const [];
  });

  group('ErrorMessageResolver', () {
    test('debug mode returns a readable Failure reason', () {
      const Failure failure = NetworkFailure(message: 'Request failed');
      final Message message = ErrorMessageResolver.resolve(
        failure,
        debug: true,
      );

      expect(message.title, 'Network Error');
      expect(message.value, 'Request failed');
      expect(message.value, isNot(contains(ErrorCodes.networkErrorRetry)));
    });

    test('debug mode returns a readable string error', () {
      final Message message = ErrorMessageResolver.resolve(
        'Something went wrong',
        debug: true,
      );

      expect(message.title, 'Unknown Error');
      expect(message.value, 'Something went wrong');
    });

    test('debug mode handles null error', () {
      final Message message = ErrorMessageResolver.resolve(null, debug: true);

      expect(message.title, 'Unknown Error');
      expect(message.value, 'An unexpected error occurred.');
    });

    test('release mode maps a known Failure to a non-empty message', () {
      final Message message = ErrorMessageResolver.resolve(
        const NoInternetFailure(),
        debug: false,
      );

      expect(message.title, isNotEmpty);
      expect(message.value, isNotEmpty);
    });

    test('release mode maps an unknown Failure without crashing', () {
      final Message message = ErrorMessageResolver.resolve(
        const UnknownFailure(message: 'Custom unknown error'),
        debug: false,
      );

      expect(message.title, isNotEmpty);
      expect(message.value, isNotEmpty);
    });

    test('preserves and formats multiple validation reasons', () {
      final Message message = ErrorMessageResolver.resolve(
        const ValidationFailure(
          message: 'Phone number is invalid.\nPassword is too short.',
        ),
        debug: true,
      );

      expect(message.title, 'Validation Error');
      expect(message.value, contains('Phone number is invalid.'));
      expect(message.value, contains('Password is too short.'));
      expect(message.value, isNot(contains('ValidationFailure')));
    });

    test('preserves a top-level server message', () {
      final Message message = ErrorMessageResolver.resolve(<String, dynamic>{
        'status': 401,
        'message': 'The phone number or password is incorrect.',
      }, debug: false);

      expect(message.title, 'Unauthorized');
      expect(message.value, 'The phone number or password is incorrect.');
    });
  });
}
