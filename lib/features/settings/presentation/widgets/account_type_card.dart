import 'package:flutter/material.dart';

import 'settings_palette.dart';

class AccountTypeCard extends StatelessWidget {
  const AccountTypeCard({
    required this.title,
    required this.description,
    this.badgeText,
    this.selected = false,
    this.badgeColor,
    this.badgeTextColor,
    this.badgeGradient,
    this.footer,
    this.minHeight,
    super.key,
  });

  final String title;
  final String description;
  final String? badgeText;
  final bool selected;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Gradient? badgeGradient;
  final Widget? footer;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: const EdgeInsetsDirectional.fromSTEB(17, 16, 17, 16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        border: selected
            ? Border.all(color: palette.accent, width: 1.4)
            : Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (badgeText != null) ...<Widget>[
                const SizedBox(width: 10),
                _AccountTypeBadge(
                  text: badgeText!,
                  color: badgeColor ?? palette.accent,
                  textColor: badgeTextColor ?? palette.onAccent,
                  gradient: badgeGradient,
                ),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          if (footer != null) ...<Widget>[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _AccountTypeBadge extends StatelessWidget {
  const _AccountTypeBadge({
    required this.text,
    required this.color,
    required this.textColor,
    this.gradient,
  });

  final String text;
  final Color color;
  final Color textColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          text,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}