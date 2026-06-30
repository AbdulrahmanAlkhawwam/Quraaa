import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../../core/errors/exceptions.dart';

class LocalExplorerPlatformDataSource {
  LocalExplorerPlatformDataSource({
    this._channel = const MethodChannel('quraaa/local_explorer'),
  });

  final MethodChannel _channel;

  bool get _usesAndroidBridge {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  Future<String?> defaultRootPath() async {
    if (!_usesAndroidBridge) {
      return null;
    }

    return _invoke<String>('defaultRootPath');
  }

  Future<bool> hasStorageAccess() async {
    if (!_usesAndroidBridge) {
      return true;
    }

    return await _invoke<bool>('hasStorageAccess') ?? false;
  }

  Future<bool> requestStorageAccess() async {
    if (!_usesAndroidBridge) {
      return true;
    }

    return await _invoke<bool>('requestStorageAccess') ?? false;
  }

  Future<T?> _invoke<T>(String method) async {
    try {
      return await _channel.invokeMethod<T>(method);
    } on PlatformException catch (error) {
      throw OperationFailedException(message: error.message);
    } on MissingPluginException catch (error) {
      throw OperationFailedException(message: '$error');
    }
  }
}
