import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/config/env/env.dart';
import 'package:quraaa/config/routes/route_names.dart';

void main() {
  test('checkout redirects use the registered Quraaa URL scheme', () {
    final Uri successUri = Uri.parse(Env.checkoutSuccessUrl);
    final Uri cancelUri = Uri.parse(Env.checkoutCancelUrl);

    expect(successUri.scheme, 'quraaa');
    expect(successUri.path, RouteNames.checkoutSuccess);
    expect(
      successUri.queryParameters['session_id'],
      '{CHECKOUT_SESSION_ID}',
    );
    expect(cancelUri.scheme, 'quraaa');
    expect(cancelUri.path, RouteNames.checkoutCancel);
  });
}
