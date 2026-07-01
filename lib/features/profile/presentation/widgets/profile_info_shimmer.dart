import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';

/// Shimmer placeholders used while the profile is being fetched.
///
/// Mirrors the shape of the profile information card so the UI does not show
/// empty text fields while loading.
class ProfileInfoShimmer extends StatelessWidget {
  const ProfileInfoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primary100,
      highlightColor: AppColors.primary50,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.radius32),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildRow(),
            const Divider(
              height: 1,
              indent: AppSpacing.spacing20,
              endIndent: AppSpacing.spacing20,
              color: AppColors.primary100,
            ),
            _buildRow(),
            const Divider(
              height: 1,
              indent: AppSpacing.spacing20,
              endIndent: AppSpacing.spacing20,
              color: AppColors.primary100,
            ),
            _buildRow(),
            const Divider(
              height: 1,
              indent: AppSpacing.spacing20,
              endIndent: AppSpacing.spacing20,
              color: AppColors.primary100,
            ),
            _buildRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing20,
        vertical: AppSpacing.spacing16,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(AppRadius.radius8),
          ),
        ),
      ),
    );
  }
}
