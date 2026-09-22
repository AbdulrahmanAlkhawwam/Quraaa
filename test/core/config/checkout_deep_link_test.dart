import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/config/app_config.dart';

void main() {
  test('checkout callbacks use the registered Quraaa URL authority', () {
    expect(AppConfig.checkoutCallbackScheme, 'quraaa');
    expect(AppConfig.checkoutCallbackHost, 'checkout');

    final Uri callback = Uri.parse(
      'quraaa://checkout/success?orderId=order-1',
    );
    expect(callback.scheme, AppConfig.checkoutCallbackScheme);
    expect(callback.host, AppConfig.checkoutCallbackHost);
    expect(callback.path, '/success');
    expect(callback.queryParameters['orderId'], 'order-1');
  });
}
