import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/config/env/env.dart';

void main() {
  test('checkout redirects use the registered Quraaa URL scheme', () {
    final Uri successUri = Uri.parse(Env.checkoutSuccessUrl);
    final Uri cancelUri = Uri.parse(Env.checkoutCancelUrl);

    expect(successUri.scheme, 'quraaa');
    expect(successUri.host, 'checkout');
    expect(successUri.path, '/success');
    expect(
      successUri.queryParameters['session_id'],
      '{CHECKOUT_SESSION_ID}',
    );
    expect(cancelUri.scheme, 'quraaa');
    expect(cancelUri.host, 'checkout');
    expect(cancelUri.path, '/cancel');
  });
}
