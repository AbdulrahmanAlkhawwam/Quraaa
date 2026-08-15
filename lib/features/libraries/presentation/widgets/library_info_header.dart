import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/library_entity.dart';

/// Logo, category tabs, description, and rating matching the library design.
class LibraryInfoHeader extends StatelessWidget {
  const LibraryInfoHeader({super.key, required this.library});

  final LibraryEntity? library;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildLogo(context),
        const SizedBox(height: AppSpacing.spacing12),
        const _LibraryTabs(),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.spacing26,
            AppSpacing.spacing28,
            AppSpacing.spacing26,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDescription(context),
              const SizedBox(height: AppSpacing.spacing10),
              _buildRating(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    final String imageUrl = library?.headerImage.trim().isNotEmpty ?? false
        ? library!.headerImage
        : library?.libraryImage ?? '';

    return SizedBox(
      height: 215,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing40,
          vertical: AppSpacing.spacing16,
        ),
        child: AppImage(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.contain,
          errorWidget: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedStore04,
              color:
                  context.isDark ? AppColors.primary300 : AppColors.primary600,
              size: 72,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final String description = library?.description?.trim().isNotEmpty ?? false
        ? library!.description!.trim()
        : LocalizationConstants.libraryDetailsDefaultDescriptionKey.tr();

    return Text(
      description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: context.isDark
            ? AppColors.textSecondaryDark
            : const Color(0xFF53664A),
        height: 1.42,
      ),
    );
  }

  Widget _buildRating(BuildContext context) {
    final double rating = (library?.rating ?? 0).clamp(0, 5).toDouble();
    final int reviewCount = library?.reviewCount ?? 0;

    return Row(
      children: <Widget>[
        ...List<Widget>.generate(5, (int index) {
          return Icon(
            index < rating.round()
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFFFC400),
            size: 22,
          );
        }),
        const SizedBox(width: AppSpacing.spacing10),
        Text(
          '$reviewCount ${LocalizationConstants.libraryDetailsReviewersKey.tr()}',
          style: AppTextStyles.bodySmall.copyWith(
            color: context.isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF607158),
          ),
        ),
      ],
    );
  }
}

class _LibraryTabs extends StatelessWidget {
  const _LibraryTabs();

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        context.isDark ? AppColors.primary300 : AppColors.primary600;
    final Color inactiveColor = context.isDark
        ? AppColors.settingsInactiveIconDark
        : AppColors.primary300;

    return Container(
      height: 62,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                context.isDark ? AppColors.outlineDark : AppColors.primary100,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.spacing26,
          end: AppSpacing.spacing18,
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: 61,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing20,
              ),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.settingsCardBackgroundDark
                    : AppColors.primary50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.radius10),
                ),
              ),
              child: Row(
                children: <Widget>[
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedStore04,
                    color: activeColor,
                    size: 27,
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Text(
                    LocalizationConstants.libraryDetailsTabGeneralKey.tr(),
                    style: AppTextStyles.bodyLarge.copyWith(color: activeColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _TabIcon(
                icon: HugeIcons.strokeRoundedLocationUser01,
                color: inactiveColor,
              ),
            ),
            Expanded(
              child: _TabIcon(
                icon: HugeIcons.strokeRoundedBuilding03,
                color: inactiveColor,
              ),
            ),
            Expanded(
              child: _TabIcon(
                icon: HugeIcons.strokeRoundedBooks01,
                color: inactiveColor,
              ),
            ),
            Expanded(
              child: _TabIcon(
                icon: HugeIcons.strokeRoundedHeadphones,
                color: inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.icon, required this.color});

  final List<List<dynamic>> icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HugeIcon(icon: icon, color: color, size: 27),
    );
  }
}
