import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/entities/settings_tab.dart';
import 'settings_palette.dart';

class SettingsTabBar extends StatelessWidget {
  const SettingsTabBar({
    required this.tabs,
    required this.activeTab,
    required this.onTabChanged,
    super.key,
  });

  final List<SettingsTab> tabs;
  final SettingsTab activeTab;
  final ValueChanged<SettingsTab> onTabChanged;

  List<List<dynamic>> _iconForKey(String key) {
    return switch (key) {
      'user' => HugeIcons.strokeRoundedId,
      'library' => HugeIcons.strokeRoundedLibrary,
      'trophy' => HugeIcons.strokeRoundedAward02,
      'clock' => HugeIcons.strokeRoundedClock01,
      'settings' => HugeIcons.strokeRoundedSettings02,
      _ => HugeIcons.strokeRoundedSettings02,
    };
  }

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: palette.background,
        border: Border(
          bottom: BorderSide(color: palette.border.withOpacity(0.45)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((SettingsTab tab) {
          final bool isActive = tab.id == activeTab.id;

          return Expanded(
            flex: isActive ? 3 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () => onTabChanged(tab),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isActive ? palette.card : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      HugeIcon(
                        icon: _iconForKey(tab.iconKey),
                        color: isActive ? palette.active : palette.inactiveIcon,
                        size: 22,
                      ),
                      if (isActive) ...<Widget>[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            tab.labelKey.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: palette.active,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
