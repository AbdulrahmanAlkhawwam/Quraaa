import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/constants/app_routes.dart';
import 'package:quraaa/core/routing/route_resolver.dart';

void main() {
  group('resolveBridgeRoute', () {
    test('returns known static routes', () {
      expect(resolveBridgeRoute(AppRoutes.home), AppRoutes.home);
      expect(resolveBridgeRoute(AppRoutes.explorer), AppRoutes.explorer);
      expect(resolveBridgeRoute(AppRoutes.pdfReader), AppRoutes.pdfReader);
      expect(resolveBridgeRoute(AppRoutes.settings), AppRoutes.settings);
    });

    test('decodes encoded route values', () {
      final String encoded = Uri.encodeComponent(AppRoutes.pdfReader);

      expect(resolveBridgeRoute(encoded), AppRoutes.pdfReader);
    });

    test('rejects empty and unknown routes', () {
      expect(resolveBridgeRoute(null), isNull);
      expect(resolveBridgeRoute(''), isNull);
      expect(resolveBridgeRoute('/not-found'), isNull);
    });
  });
}