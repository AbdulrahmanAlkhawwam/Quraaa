import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/styles/text_styles.dart';

class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({
    super.key,
    required this.title,
    required this.onTap,
    this.leadingIcon,
    this.leadingIconColor = AppColors.primary600,
    this.trailingIcon = HugeIcons.strokeRoundedArrowRight01,
    this.trailingIconColor = AppColors.primary600,
    this.backgroundColor = Colors.transparent,
    this.titleColor = AppColors.textPrimary,
    this.subtitle,
  });

  final String title;
  final VoidCallback onTap;
  final List<List<dynamic>>? leadingIcon;
  final Color leadingIconColor;
  final List<List<dynamic>> trailingIcon;
  final Color trailingIconColor;
  final Color backgroundColor;
  final Color titleColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing20,
            vertical: AppSpacing.spacing18,
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                HugeIcon(
                  icon: leadingIcon!,
                  color: leadingIconColor,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.spacing12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.spacing4),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              HugeIcon(
                icon: trailingIcon,
                color: trailingIconColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
