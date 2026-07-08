import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/entities/settings_section.dart';
import 'settings_palette.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    required this.section,
    required this.onTap,
    super.key,
  });

  final SettingsSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  section.labelKey.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: palette.inactiveIcon,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
