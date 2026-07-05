import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

@immutable
class SettingsPalette {
  const SettingsPalette({
    required this.isDark,
    required this.background,
    required this.header,
    required this.sheet,
    required this.card,
    required this.text,
    required this.secondaryText,
    required this.accent,
    required this.active,
    required this.inactiveIcon,
    required this.border,
    required this.divider,
    required this.searchFill,
    required this.logout,
    required this.scrim,
    required this.switchTrack,
    required this.switchOffThumb,
    required this.onAccent,
  });

  final bool isDark;
  final Color background;
  final Color header;
  final Color sheet;
  final Color card;
  final Color text;
  final Color secondaryText;
  final Color accent;
  final Color active;
  final Color inactiveIcon;
  final Color border;
  final Color divider;
  final Color searchFill;
  final Color logout;
  final Color scrim;
  final Color switchTrack;
  final Color switchOffThumb;
  final Color onAccent;

  static const SettingsPalette light = SettingsPalette(
    isDark: false,
    background: AppColors.settingsBackground,
    header: AppColors.settingsHeader,
    sheet: AppColors.surfaceLight,
    card: AppColors.settingsCardBackground,
    text: AppColors.textPrimary,
    secondaryText: AppColors.textSecondary,
    accent: AppColors.settingsAccentGreen,
    active: AppColors.settingsActiveGreen,
    inactiveIcon: AppColors.settingsInactiveIcon,
    border: AppColors.settingsBorder,
    divider: AppColors.surfaceLight,
    searchFill: AppColors.surfaceLight,
    logout: AppColors.settingsLogout,
    scrim: Color(0x66000000),
    switchTrack: AppColors.surfaceLight,
    switchOffThumb: AppColors.settingsToggleInactive,
    onAccent: AppColors.surfaceLight,
  );

  static const SettingsPalette dark = SettingsPalette(
    isDark: true,
    background: AppColors.settingsBackgroundDark,
    header: AppColors.settingsHeaderDark,
    sheet: AppColors.settingsSheetDark,
    card: AppColors.settingsCardBackgroundDark,
    text: AppColors.settingsTextDark,
    secondaryText: AppColors.settingsTextMutedDark,
    accent: AppColors.settingsActiveGreenDark,
    active: AppColors.settingsActiveGreenDark,
    inactiveIcon: AppColors.settingsInactiveIconDark,
    border: AppColors.settingsBorderDark,
    divider: AppColors.settingsSheetDark,
    searchFill: Color(0xFF101B12),
    logout: AppColors.settingsLogoutDark,
    scrim: Color(0xA6000000),
    switchTrack: Color(0xFF0E170F),
    switchOffThumb: Color(0xFF41643B),
    onAccent: AppColors.settingsBackgroundDark,
  );

  static SettingsPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
