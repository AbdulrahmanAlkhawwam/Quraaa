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
    super.key,
  });

  final String title;
  final String description;
  final String? badgeText;
  final bool selected;
  final Color? badgeColor;
  final Color? badgeTextColor;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(6),
        border: selected
            ? Border.all(color: palette.accent, width: 1.4)
            : Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (badgeText != null) ...<Widget>[
                const SizedBox(width: 10),
                _AccountTypeBadge(
                  text: badgeText!,
                  color: badgeColor ?? palette.accent,
                  textColor: badgeTextColor ?? palette.onAccent,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  fontSize: 13,
                  height: 1.3,
                ),
          ),
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
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          text,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
        ),
      ),
    );
  }
}
