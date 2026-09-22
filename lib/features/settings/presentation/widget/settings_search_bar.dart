import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import 'settings_palette.dart';

class SettingsSearchBar extends StatelessWidget {
  const SettingsSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(40, 30, 40, 22),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: palette.text,
            ),
        decoration: InputDecoration(
          hintText: LocalizationConstants.settingsSearchHintKey.tr(),
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.inactiveIcon,
                fontWeight: FontWeight.w500,
              ),
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: 20),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: palette.inactiveIcon,
              size: 31,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 58),
          filled: true,
          fillColor: palette.searchFill,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(28, 18, 12, 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(34),
            borderSide: BorderSide(color: palette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(34),
            borderSide: BorderSide(color: palette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(34),
            borderSide: BorderSide(color: palette.accent, width: 1.4),
          ),
        ),
      ),
    );
  }
}
