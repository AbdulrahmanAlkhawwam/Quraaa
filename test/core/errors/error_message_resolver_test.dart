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
    test('debug mode returns raw Failure details', () {
      const Failure failure = NetworkFailure(message: 'Request failed');
      final Message message = ErrorMessageResolver.resolve(failure, debug: true);

      expect(message.title, 'NetworkFailure (${ErrorCodes.networkErrorRetry})');
      expect(message.value, failure.toString());
    });

    test('debug mode returns raw string for non-Failure errors', () {
      final Message message = ErrorMessageResolver.resolve(
        'Something went wrong',
        debug: true,
      );

      expect(message.title, 'Debug Error');
      expect(message.value, 'Something went wrong');
    });

    test('debug mode handles null error', () {
      final Message message = ErrorMessageResolver.resolve(null, debug: true);

      expect(message.title, 'Debug Error');
      expect(message.value, 'Unknown error');
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
  });
}
