import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/library_book_entity.dart';

/// Compact book presentation used in the recently-added carousel.
class LibraryDetailsBookCard extends StatelessWidget {
  const LibraryDetailsBookCard({super.key, required this.book, this.onTap});

  final LibraryBookEntity book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 90,
              height: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius4),
                child: ColoredBox(
                  color: context.appSubtleSurface,
                  child: book.coverImageUrl.isNotEmpty
                      ? AppImage(
                          book.coverImageUrl,
                          width: 90,
                          height: 140,
                          fit: BoxFit.cover,
                          errorWidget: _placeholder(context),
                        )
                      : _placeholder(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.appTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              book.author,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: context.appTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.book_outlined,
        color: context.isDark ? AppColors.primary300 : AppColors.primary600,
        size: 38,
      ),
    );
  }
}
