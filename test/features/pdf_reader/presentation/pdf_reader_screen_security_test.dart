import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/pdf_reader/presentation/services/pdf_reader_screen_security.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('quraaa/screen_security');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends secure state changes to the native platform', () async {
    final List<MethodCall> calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return null;
    });

    const PlatformPdfReaderScreenSecurity security =
        PlatformPdfReaderScreenSecurity();

    await security.setSecure(true);
    await security.setSecure(false);

    expect(calls, hasLength(2));
    expect(calls.first.method, 'setSecure');
    expect(calls.first.arguments, <String, bool>{'enabled': true});
    expect(calls.last.arguments, <String, bool>{'enabled': false});
  });
}
