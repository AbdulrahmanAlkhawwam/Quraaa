import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/library_entity.dart';

/// Header section of the library details screen: logo, chips, description, rating.
class LibraryInfoHeader extends StatelessWidget {
  const LibraryInfoHeader({
    super.key,
    required this.library,
  });

  final LibraryEntity library;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildImage(context),
        const SizedBox(height: AppSpacing.spacing16),
        _buildCategoryChips(context),
        const SizedBox(height: AppSpacing.spacing16),
        _buildDescription(context),
        const SizedBox(height: AppSpacing.spacing12),
        _buildRating(context),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final String imageUrl = library.headerImage.isNotEmpty
        ? library.headerImage
        : library.libraryImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: AppImage(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: Container(
            color: AppColors.primary100,
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedStore04,
                color: AppColors.primary600,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final List<_CategoryChipData> chips = <_CategoryChipData>[
      const _CategoryChipData(
        label: 'General',
        icon: HugeIcons.strokeRoundedStore04,
        isSelected: true,
      ),
      const _CategoryChipData(
        label: 'Profile',
        icon: HugeIcons.strokeRoundedUser,
      ),
      const _CategoryChipData(
        label: 'Branches',
        icon: HugeIcons.strokeRoundedBuilding03,
      ),
      const _CategoryChipData(
        label: 'Books',
        icon: HugeIcons.strokeRoundedBooks01,
      ),
      const _CategoryChipData(
        label: 'Audio',
        icon: HugeIcons.strokeRoundedHeadphones,
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.spacing10),
        itemBuilder: (BuildContext context, int index) {
          final _CategoryChipData chip = chips[index];
          return _CategoryChip(data: chip);
        },
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final String description = library.description ??
        LocalizationConstants.libraryDetailsDefaultDescriptionKey.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      child: Text(
        description,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildRating(BuildContext context) {
    final double rating = library.rating ?? 5.0;
    final int reviewCount = library.reviewCount ?? 753;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      child: Row(
        children: <Widget>[
          Row(
            children: List<Widget>.generate(5, (int index) {
              return Icon(
                index < rating.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: AppColors.warning500,
                size: 20,
              );
            }),
          ),
          const SizedBox(width: AppSpacing.spacing8),
          Text(
            '$reviewCount ${LocalizationConstants.libraryDetailsReviewersKey.tr()}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChipData {
  const _CategoryChipData({
    required this.label,
    required this.icon,
    this.isSelected = false,
  });

  final String label;
  final List<List<dynamic>> icon;
  final bool isSelected;
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.data});

  final _CategoryChipData data;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        data.isSelected ? AppColors.primary600 : AppColors.primary600;
    final Color backgroundColor =
        data.isSelected ? AppColors.primary100 : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing14,
        vertical: AppSpacing.spacing8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius24),
        border: Border.all(
          color: data.isSelected ? AppColors.primary100 : AppColors.primary300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HugeIcon(
            icon: data.icon,
            color: foregroundColor,
            size: 22,
          ),
          if (data.isSelected) ...<Widget>[
            const SizedBox(width: AppSpacing.spacing8),
            Text(
              data.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
