import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/library_book_entity.dart';

/// A book card used in the "Recently added" section of the library details screen.
class LibraryDetailsBookCard extends StatelessWidget {
  const LibraryDetailsBookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  final LibraryBookEntity book;
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius16),
                child: Container(
                  color: AppColors.primary100,
                  child: book.coverImageUrl.isNotEmpty
                      ? AppImage(
                          book.coverImageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: _placeholder(),
                        )
                      : _placeholder(),
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
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              book.author,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.appTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.book_outlined,
        color: AppColors.primary600,
        size: 40,
      ),
    );
  }
}
