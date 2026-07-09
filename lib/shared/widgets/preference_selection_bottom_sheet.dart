import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/styles/text_styles.dart';
import 'bottom_sheet_drag_handle.dart';

class PreferenceSelectionOption<T> {
  const PreferenceSelectionOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.leadingIcon,
  });

  final T value;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
}

class PreferenceSelectionBottomSheet<T> extends StatelessWidget {
  const PreferenceSelectionBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    required this.selectedValue,
  });

  final String title;
  final String? subtitle;
  final List<PreferenceSelectionOption<T>> options;
  final T selectedValue;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<PreferenceSelectionOption<T>> options,
    required T selectedValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => PreferenceSelectionBottomSheet<T>(
        title: title,
        subtitle: subtitle,
        options: options,
        selectedValue: selectedValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.radius40),
            topRight: Radius.circular(AppRadius.radius40),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const BottomSheetDragHandle(),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.spacing24,
                  AppSpacing.spacing8,
                  AppSpacing.spacing24,
                  AppSpacing.spacing12,
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h4.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.spacing8),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spacing12,
                ),
                child: Column(
                  children: options.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final PreferenceSelectionOption<T> option = entry.value;
                    final bool selected = option.value == selectedValue;

                    return Column(
                      children: <Widget>[
                        _PreferenceSelectionTile<T>(
                          option: option,
                          selected: selected,
                          onTap: () => Navigator.of(context).pop(option.value),
                        ),
                        if (index != options.length - 1)
                          const SizedBox(height: AppSpacing.spacing4),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceSelectionTile<T> extends StatelessWidget {
  const _PreferenceSelectionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final PreferenceSelectionOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      child: Material(
        color: selected ? colors.primaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.radius24),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing16,
            ),
            child: Row(
              children: <Widget>[
                if (option.leadingIcon != null) ...<Widget>[
                  Icon(
                    option.leadingIcon,
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        option.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (option.subtitle != null &&
                          option.subtitle!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.spacing4),
                        Text(
                          option.subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey<String>('selected'),
                          color: colors.primary,
                          size: 22,
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey<String>('unselected'),
                          color: colors.onSurfaceVariant,
                          size: 22,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
