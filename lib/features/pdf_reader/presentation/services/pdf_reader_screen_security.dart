import 'package:flutter/services.dart';

abstract interface class PdfReaderScreenSecurity {
  Future<void> setSecure(bool enabled);
}

final class PlatformPdfReaderScreenSecurity implements PdfReaderScreenSecurity {
  const PlatformPdfReaderScreenSecurity();

  static const MethodChannel _channel = MethodChannel(
    'quraaa/screen_security',
  );

  @override
  Future<void> setSecure(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setSecure', <String, bool>{
        'enabled': enabled,
      });
    } on MissingPluginException {
      // Screenshot blocking is only available on supported native platforms.
    }
  }
}
