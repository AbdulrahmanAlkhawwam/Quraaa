import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/config/env/env.dart';

void main() {
  test('checkout callbacks use the registered Quraaa URL authority', () {
    expect(Env.checkoutCallbackScheme, 'quraaa');
    expect(Env.checkoutCallbackHost, 'checkout');

    final Uri callback = Uri.parse(
      'quraaa://checkout/success?orderId=order-1',
    );
    expect(callback.scheme, Env.checkoutCallbackScheme);
    expect(callback.host, Env.checkoutCallbackHost);
    expect(callback.path, '/success');
    expect(callback.queryParameters['orderId'], 'order-1');
  });
}
