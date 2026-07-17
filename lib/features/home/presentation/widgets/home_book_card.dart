import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';
import '../models/home_book.dart';

/// A book item used in horizontal lists on the home screen.
class HomeBookCard extends StatelessWidget {
  const HomeBookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  final HomeBook book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: book.coverColors ??
                        <Color>[
                          AppColors.primary400,
                          AppColors.primary600,
                        ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.radius16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedBookOpen02,
                        color: AppColors.card,
                        size: 40,
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      Text(
                        'Emar',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.card,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing10),
            Text(
              book.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (book.subtitle != null && book.subtitle!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.spacing4),
                child: Text(
                  book.subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.spacing4),
              child: Text(
                book.size,
                style: AppTextStyles.caption.copyWith(
                  color: context.appTextTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
