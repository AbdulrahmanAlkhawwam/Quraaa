import 'dart:ui';

import 'package:dio/dio.dart';

import '../constants/app_storage_keys.dart';
import '../services/storage_service.dart';

/// Adds the app's selected language to every outgoing API request.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._storageService);

  final StorageService _storageService;

  static const Set<String> _supportedLanguages = <String>{'ar', 'en'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('Accept-Language', () => _currentLanguage);
    handler.next(options);
  }

  String get _currentLanguage {
    final String? storedLanguage = _storageService.getString(
      AppStorageKeys.userLanguage,
    );
    if (_supportedLanguages.contains(storedLanguage)) {
      return storedLanguage!;
    }

    final String deviceLanguage =
        PlatformDispatcher.instance.locale.languageCode;
    return _supportedLanguages.contains(deviceLanguage) ? deviceLanguage : 'en';
  }
}
