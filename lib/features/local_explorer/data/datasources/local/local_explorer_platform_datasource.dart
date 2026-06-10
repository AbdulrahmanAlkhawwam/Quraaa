import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocalExplorerPlatformDataSource {
  LocalExplorerPlatformDataSource({
    MethodChannel channel = const MethodChannel('quraaa/local_explorer'),
  }) : _channel = channel;

  final MethodChannel _channel;

  bool get _usesAndroidBridge {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  Future<String?> defaultRootPath() async {
    if (!_usesAndroidBridge) {
      return null;
    }

    return _channel.invokeMethod<String>('defaultRootPath');
  }

  Future<bool> hasStorageAccess() async {
    if (!_usesAndroidBridge) {
      return true;
    }

    return await _channel.invokeMethod<bool>('hasStorageAccess') ?? false;
  }

  Future<bool> requestStorageAccess() async {
    if (!_usesAndroidBridge) {
      return true;
    }

    return await _channel.invokeMethod<bool>('requestStorageAccess') ?? false;
  }
}
