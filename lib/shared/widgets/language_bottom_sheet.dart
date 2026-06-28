import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_storage_keys.dart';
import '../../core/di/injection_container.dart';
import '../../core/localization/localization_constants.dart';
import '../../core/localization/supported_locales.dart';
import '../../core/services/storage_service.dart';
import 'preference_selection_bottom_sheet.dart';

class LanguageBottomSheet {
  LanguageBottomSheet._();

  static Future<void> show(BuildContext context) async {
    final Locale? selected = await PreferenceSelectionBottomSheet.show<Locale>(
      context,
      title: LocalizationConstants.settingsLanguageTitleKey.tr(),
      subtitle: LocalizationConstants.settingsLanguageSubtitleKey.tr(),
      selectedValue: context.locale,
      options: <PreferenceSelectionOption<Locale>>[
        PreferenceSelectionOption<Locale>(
          value: SupportedLocales.english,
          title: LocalizationConstants.settingsLanguageEnglishKey.tr(),
          subtitle: LocalizationConstants.settingsLanguageEnglishDescKey.tr(),
          leadingIcon: Icons.language_rounded,
        ),
        PreferenceSelectionOption<Locale>(
          value: SupportedLocales.arabic,
          title: LocalizationConstants.settingsLanguageArabicKey.tr(),
          subtitle: LocalizationConstants.settingsLanguageArabicDescKey.tr(),
          leadingIcon: Icons.language_rounded,
        ),
      ],
    );

    if (selected == null || !context.mounted) {
      return;
    }

    await context.setLocale(selected);
    await sl<StorageService>().setString(
      AppStorageKeys.userLanguage,
      selected.languageCode,
    );
  }
}
