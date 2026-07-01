import 'package:flutter/material.dart';

import '../../domain/entities/settings_section.dart';
import '../../domain/entities/settings_tab.dart';
import 'settings_list_tile.dart';
import 'settings_logout_button.dart';

class SettingsSectionList extends StatelessWidget {
  const SettingsSectionList({
    required this.activeTab,
    required this.sections,
    required this.onSectionTap,
    required this.onLogoutTap,
    super.key,
  });

  final SettingsTab activeTab;
  final List<SettingsSection> sections;
  final ValueChanged<SettingsSection> onSectionTap;
  final VoidCallback onLogoutTap;

  List<List<SettingsSection>> _groupedSections() {
    if (activeTab.id != 'profile' || sections.length < 7) {
      return <List<SettingsSection>>[sections];
    }

    return <List<SettingsSection>>[
      sections.sublist(0, 2),
      sections.sublist(2, 5),
      sections.sublist(5, 7),
    ];
  }

  Widget _buildGroup(List<SettingsSection> group) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: group.asMap().entries.map((MapEntry<int, SettingsSection> entry) {
        final bool isFirst = entry.key == 0;
        final bool isLast = entry.key == group.length - 1;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              if (!isFirst) const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(isFirst ? 8 : 0),
                  bottom: Radius.circular(isLast ? 8 : 0),
                ),
                child: SettingsListTile(
                  section: entry.value,
                  onTap: () => onSectionTap(entry.value),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<List<SettingsSection>> groups = _groupedSections();

    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          const SizedBox(height: 30),
          ...groups.map(_buildGroup).expand(
                (Widget group) => <Widget>[group, const SizedBox(height: 30)],
              ),
          if (activeTab.id == 'profile') ...<Widget>[
            const SizedBox(height: 200),
            SettingsLogoutButton(onPressed: onLogoutTap),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
