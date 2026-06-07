import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'localization_constants.dart';
import 'supported_locales.dart';

class LocalizationService {
  LocalizationService._();

  static Future<void> ensureInitialized() => EasyLocalization.ensureInitialized();

  static Widget wrap({required Widget child}) {
    return EasyLocalization(
      supportedLocales: SupportedLocales.all,
      path: LocalizationConstants.translationsPath,
      fallbackLocale: SupportedLocales.fallback,
      startLocale: SupportedLocales.fallback,
      saveLocale: false,
      useOnlyLangCode: true,
      child: child,
    );
  }
}

extension LocalizationStringX on String {
  String localized({List<String>? args}) => tr('',args: args);
}

extension LocalizationContextX on BuildContext {
  Locale get appLocale => locale;

  bool get isRtlLocale => SupportedLocales.isRtl(locale);

  Future<void> changeLocale(Locale newLocale) => setLocale(newLocale);

  String translate(String key, {List<String>? args}) => key.tr(args: args);
}
