import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/appearance_option.dart';
import 'settings_palette.dart';
import 'settings_sheet_title_bar.dart';

class AppearanceBottomSheet extends StatelessWidget {
  const AppearanceBottomSheet({
    required this.options,
    required this.onSelected,
    super.key,
  });

  final List<AppearanceOption> options;
  final ValueChanged<AppearanceOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(28, 40, 28, bottomInset + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingsSheetTitleBar(title: 'settings.appearance.title'.tr()),
            const SizedBox(height: 24),
            ...options.map((AppearanceOption option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _AppearanceOptionCard(
                  option: option,
                  onTap: () {
                    onSelected(option);
                    Navigator.of(context).pop();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AppearanceOptionCard extends StatelessWidget {
  const _AppearanceOptionCard({
    required this.option,
    required this.onTap,
  });

  final AppearanceOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(8),
          border: option.selected
              ? Border.all(color: palette.accent, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              option.labelKey.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: option.selected ? palette.text : palette.active,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 14),
            _AppearancePreview(mode: option.mode),
          ],
        ),
      ),
    );
  }
}

class _AppearancePreview extends StatelessWidget {
  const _AppearancePreview({required this.mode});

  final AppearanceMode mode;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);
    final Color lightLine = palette.isDark ? palette.sheet : Colors.white;
    final Color greenLine =
        palette.isDark ? palette.accent : const Color(0xFF3F7F2D);

    final List<Color> lines = switch (mode) {
      AppearanceMode.light => <Color>[
          lightLine,
          lightLine,
          lightLine,
          lightLine,
          lightLine,
          lightLine,
          lightLine,
          lightLine,
          lightLine,
        ],
      AppearanceMode.dark => <Color>[
          greenLine,
          greenLine,
          greenLine,
          greenLine,
          greenLine,
          greenLine,
          greenLine,
          greenLine,
          greenLine,
        ],
      AppearanceMode.system => <Color>[
          greenLine,
          lightLine,
          greenLine,
          lightLine,
          greenLine,
          lightLine,
          lightLine,
          greenLine,
          greenLine,
        ],
    };

    return Column(
      children: <Widget>[
        _PreviewRow(colors: lines.sublist(0, 3), flexes: const <int>[6, 2, 4]),
        const SizedBox(height: 12),
        _PreviewRow(colors: lines.sublist(3, 6), flexes: const <int>[3, 4, 4]),
        const SizedBox(height: 12),
        _PreviewRow(colors: lines.sublist(6, 9), flexes: const <int>[1, 5, 3]),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.colors,
    required this.flexes,
  });

  final List<Color> colors;
  final List<int> flexes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(colors.length, (int index) {
        return Expanded(
          flex: flexes[index],
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == colors.length - 1 ? 0 : 14,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(2),
              ),
              child: const SizedBox(height: 12),
            ),
          ),
        );
      }),
    );
  }
}
