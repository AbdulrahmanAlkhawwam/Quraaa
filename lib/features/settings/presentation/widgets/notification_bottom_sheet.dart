import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/entities/notification_setting.dart';
import 'settings_palette.dart';
import 'settings_sheet_title_bar.dart';

class NotificationBottomSheet extends StatefulWidget {
  const NotificationBottomSheet({
    required this.settings,
    required this.onToggle,
    super.key,
  });

  final List<NotificationSetting> settings;
  final ValueChanged<NotificationSetting> onToggle;

  @override
  State<NotificationBottomSheet> createState() {
    return _NotificationBottomSheetState();
  }
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet> {
  late List<NotificationSetting> _settings = widget.settings;

  @override
  void didUpdateWidget(covariant NotificationBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _settings = widget.settings;
    }
  }

  void _toggle(NotificationSetting setting) {
    final NotificationSetting updated = setting.copyWith(value: !setting.value);

    setState(() {
      _settings = _settings.map((NotificationSetting item) {
        return item.id == setting.id ? updated : item;
      }).toList(growable: false);
    });

    widget.onToggle(updated);
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final List<NotificationSetting> firstGroup = _settings.take(4).toList();
    final List<NotificationSetting> secondGroup = _settings.skip(4).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(28, 40, 28, bottomInset + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingsSheetTitleBar(title: 'settings.notification.title'.tr()),
            const SizedBox(height: 28),
            _NotificationGroup(
              settings: firstGroup,
              onToggle: _toggle,
            ),
            const SizedBox(height: 30),
            _NotificationGroup(
              settings: secondGroup,
              onToggle: _toggle,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.settings,
    required this.onToggle,
  });

  final List<NotificationSetting> settings;
  final ValueChanged<NotificationSetting> onToggle;

  @override
  Widget build(BuildContext context) {
    if (settings.isEmpty) {
      return const SizedBox.shrink();
    }

    final SettingsPalette palette = SettingsPalette.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(color: palette.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(settings.length, (int index) {
            final NotificationSetting setting = settings[index];
            final bool isLast = index == settings.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _NotificationRow(
                  setting: setting,
                  onTap: () => onToggle(setting),
                ),
                if (!isLast)
                  Divider(
                    height: 2,
                    thickness: 2,
                    color: palette.divider,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.setting,
    required this.onTap,
  });

  final NotificationSetting setting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        setting.labelKey.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: palette.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    if (setting.id == 'new_book_version') ...<Widget>[
                      const SizedBox(width: 8),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedInformationCircle,
                        color: palette.inactiveIcon,
                        size: 15,
                      ),
                    ],
                  ],
                ),
              ),
              _SettingsSwitch(
                value: setting.value,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.value,
    required this.onTap,
  });

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 60,
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: palette.switchTrack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? palette.accent : palette.switchOffThumb,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
