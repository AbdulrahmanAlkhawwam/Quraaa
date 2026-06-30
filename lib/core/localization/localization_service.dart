import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'localization_constants.dart';
import 'supported_locales.dart';

class LocalizationService {
  LocalizationService._();

  static Future<void> ensureInitialized() => EasyLocalization.ensureInitialized();

  static Widget wrap({required Widget child, Locale? startLocale}) {
    return EasyLocalization(
      supportedLocales: SupportedLocales.all,
      path: LocalizationConstants.translationsPath,
      fallbackLocale: SupportedLocales.fallback,
      startLocale: startLocale ?? SupportedLocales.fallback,
      saveLocale: false,
      useOnlyLangCode: true,
      child: child,
    );
  }
}


