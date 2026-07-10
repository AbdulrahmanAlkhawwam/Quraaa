import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/settings_tab.dart';
import 'settings_palette.dart';

class SettingsHeader extends SliverPersistentHeaderDelegate {
  const SettingsHeader({required this.activeTab});

  final SettingsTab activeTab;

  static const double _expandedHeight = 380;
  static const double _collapsedHeight = 72;
  static const double _avatarMaxSize = 210;

  double _progress(double shrinkOffset) {
    return (shrinkOffset / (_expandedHeight - _collapsedHeight)).clamp(0, 1);
  }

  @override
  double get maxExtent => _expandedHeight;

  @override
  double get minExtent => _collapsedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double progress = _progress(shrinkOffset);
    final double avatarSize = _avatarMaxSize * (1 - progress);
    final double avatarOpacity = 1 - progress;
    final SettingsPalette palette = SettingsPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.header,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 32,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 1 - progress,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        tooltip:
                            MaterialLocalizations.of(context).backButtonTooltip,
                        onPressed: () => context.back(),
                        icon: HugeIcon(
                          icon: context.isRTL ? HugeIcons.strokeRoundedArrowRight01 : HugeIcons.strokeRoundedArrowLeft01,
                          color: palette.text,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          LocalizationConstants.settingsTitleKey.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.explorerTitle().copyWith(
                            color: palette.text,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      if (activeTab.id == 'settings')
                        IconButton(
                          tooltip: LocalizationConstants.settingsEditKey.tr(),
                          onPressed: () {
                            // Placeholder: edit settings is not supported yet.
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            color: palette.text,
                            size: 27,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Opacity(
                opacity: avatarOpacity,
                child: SizedBox(
                  width: avatarSize,
                  height: avatarSize,
                  child: avatarSize > 40
                      ? SvgPicture.asset(
                          AppIcons.man,
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SettingsHeader oldDelegate) {
    return true;
  }
}
