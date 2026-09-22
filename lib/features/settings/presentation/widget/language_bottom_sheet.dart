import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/language_option.dart';
import 'settings_palette.dart';
import 'settings_sheet_title_bar.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({
    required this.options,
    required this.onSelected,
    super.key,
  });

  final List<LanguageOption> options;
  final ValueChanged<LanguageOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(28, 40, 28, bottomInset + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingsSheetTitleBar(title: 'settings.language.title'.tr()),
            const SizedBox(height: 26),
            ...options.map((LanguageOption option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _LanguageOptionButton(
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

class _LanguageOptionButton extends StatelessWidget {
  const _LanguageOptionButton({
    required this.option,
    required this.onTap,
  });

  final LanguageOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);
    final bool selected = option.selected;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? palette.accent : palette.sheet,
          foregroundColor: selected ? palette.onAccent : palette.accent,
          side: BorderSide(
            color: selected ? palette.accent : palette.border,
            width: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          option.labelKey.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? palette.onAccent : palette.accent,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
