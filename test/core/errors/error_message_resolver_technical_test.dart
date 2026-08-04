import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/errors/error_message_resolver.dart';
import 'package:quraaa/shared/models/message.dart';

void main() {
  setUpAll(() => EasyLocalization.logger.enableLevels = const []);

  test('does not expose Dio diagnostics to the user', () {
    const String technicalMessage =
        'This exception was thrown because the response has a status code '
        'of 401 and RequestOptions.validateStatus was configured to throw.';

    final Message message = ErrorMessageResolver.resolve(technicalMessage);

    expect(message.title, 'Unknown Error');
    expect(message.value, 'An unexpected error occurred.');
    expect(message.value, isNot(contains('validateStatus')));
    expect(message.value, isNot(contains('status code')));
  });
}
