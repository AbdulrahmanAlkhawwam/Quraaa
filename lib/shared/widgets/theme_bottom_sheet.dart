import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/localization/localization_constants.dart';
import '../theme/app_theme_cubit.dart';
import 'preference_selection_bottom_sheet.dart';

class ThemeBottomSheet {
  ThemeBottomSheet._();

  static Future<void> show(BuildContext context) async {
    final ThemeMode? selected = await PreferenceSelectionBottomSheet.show<ThemeMode>(
      context,
      title: LocalizationConstants.settingsThemeTitleKey.tr(),
      subtitle: LocalizationConstants.settingsThemeSubtitleKey.tr(),
      selectedValue: context.read<AppThemeCubit>().state,
      options: <PreferenceSelectionOption<ThemeMode>>[
        PreferenceSelectionOption<ThemeMode>(
          value: ThemeMode.system,
          title: LocalizationConstants.settingsThemeSystemKey.tr(),
          subtitle: LocalizationConstants.settingsThemeSystemDescKey.tr(),
          leadingIcon: Icons.settings_suggest_rounded,
        ),
        PreferenceSelectionOption<ThemeMode>(
          value: ThemeMode.light,
          title: LocalizationConstants.settingsThemeLightKey.tr(),
          subtitle: LocalizationConstants.settingsThemeLightDescKey.tr(),
          leadingIcon: Icons.light_mode_rounded,
        ),
        PreferenceSelectionOption<ThemeMode>(
          value: ThemeMode.dark,
          title: LocalizationConstants.settingsThemeDarkKey.tr(),
          subtitle: LocalizationConstants.settingsThemeDarkDescKey.tr(),
          leadingIcon: Icons.dark_mode_rounded,
        ),
      ],
    );

    if (selected == null || !context.mounted) {
      return;
    }

    await context.read<AppThemeCubit>().setThemeMode(selected);
  }
}
