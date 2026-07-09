import 'package:flutter/material.dart';

import '../../../../../shared/extensions/app_context.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_radius.dart';
import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/theme/styles/text_styles.dart';

class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.features,
    required this.onTap,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final String price;
  final List<String> features;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.appSubtleSurface : context.appCard,
      borderRadius: BorderRadius.circular(AppRadius.radius32),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.spacing20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius32),
            border: Border.all(
              color: selected ? AppColors.primary500 : context.appBorder,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: AppTextStyles.h4.copyWith(
                            color: context.appTextPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing4),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.appTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary600 : Colors.transparent,
                      border: Border.all(color: AppColors.primary300),
                    ),
                    child: selected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: AppColors.card,
                              size: 14,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing16),
              Text(
                price,
                style: AppTextStyles.h3.copyWith(
                  color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              ...features.map(
                (String feature) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.spacing10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.primary600,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacing8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.appTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
