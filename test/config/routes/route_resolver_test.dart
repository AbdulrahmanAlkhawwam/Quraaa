import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/config/routes/route_names.dart';
import 'package:quraaa/config/routes/route_resolver.dart';

void main() {
  group('resolveBridgeRoute', () {
    test('returns known static routes', () {
      expect(resolveBridgeRoute(RouteNames.home), RouteNames.home);
      expect(resolveBridgeRoute(RouteNames.explorer), RouteNames.explorer);
      expect(resolveBridgeRoute(RouteNames.pdfReader), RouteNames.pdfReader);
      expect(resolveBridgeRoute(RouteNames.settings), RouteNames.settings);
    });

    test('decodes encoded route values', () {
      final String encoded = Uri.encodeComponent(RouteNames.pdfReader);

      expect(resolveBridgeRoute(encoded), RouteNames.pdfReader);
    });

    test('rejects empty and unknown routes', () {
      expect(resolveBridgeRoute(null), isNull);
      expect(resolveBridgeRoute(''), isNull);
      expect(resolveBridgeRoute('/not-found'), isNull);
    });
  });
}