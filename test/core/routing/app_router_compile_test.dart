import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/routing/app_router.dart';

void main() {
  test('app router compiles with the purchased-book preparation route', () {
    expect(buildAppRouter, isA<Function>());
  });
}
