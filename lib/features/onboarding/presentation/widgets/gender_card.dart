import 'package:flutter/material.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/gender_selection.dart';

class GenderCard extends StatelessWidget {
  const GenderCard({
    super.key,
    required this.gender,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final GenderSelection gender;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          decoration: BoxDecoration(
            color: selected ? context.appSubtleSurface : context.appCard,
            borderRadius: BorderRadius.circular(AppRadius.radius32),
            border: Border.all(
              color: selected ? AppColors.primary300 : context.appBorder,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImage(
                gender == GenderSelection.boy
                    ? AppImages.boyImage
                    : AppImages.girlImage,
                height: AppDimensions.onboardingAvatarSize,
              ),
              const SizedBox(height: AppSpacing.spacing24),
              Text(
                label,
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.appTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
