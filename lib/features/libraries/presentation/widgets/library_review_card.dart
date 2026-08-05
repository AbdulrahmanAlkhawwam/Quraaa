import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../models/library_review_view_model.dart';

class LibraryReviewCard extends StatelessWidget {
  const LibraryReviewCard({super.key, required this.review});

  final LibraryReviewViewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.spacing16,
        AppSpacing.spacing14,
        AppSpacing.spacing16,
        AppSpacing.spacing14,
      ),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.settingsCardBackgroundDark
            : AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.radius20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: List<Widget>.generate(5, (int index) {
              return Icon(
                index < review.rating.clamp(0, 5)
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFFFC400),
                size: 20,
              );
            }),
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Text(
            review.comment,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF53664A),
              height: 1.32,
            ),
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.spacing10),
          Row(
            children: <Widget>[
              ClipOval(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: review.reviewerImageUrl.isNotEmpty
                      ? AppImage(
                          review.reviewerImageUrl,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorWidget: _avatarPlaceholder(context),
                        )
                      : _avatarPlaceholder(context),
                ),
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Expanded(
                child: Text(
                  review.reviewerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(BuildContext context) {
    return ColoredBox(
      color: context.isDark ? AppColors.outlineDark : AppColors.primary100,
      child: Icon(
        Icons.person,
        size: 16,
        color: context.isDark ? AppColors.primary300 : AppColors.primary600,
      ),
    );
  }
}
