import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/home_book_entity.dart';

/// A book item used in horizontal lists on the home screen.
class HomeBookCard extends StatelessWidget {
  const HomeBookCard({super.key, required this.book, this.onTap});

  final HomeBookEntity book;
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
                child: book.coverImageUrl.isEmpty
                    ? const _BookCoverFallback()
                    : AppImage(
                        book.coverImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: const _BookCoverFallback(),
                        errorWidget: const _BookCoverFallback(),
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
            if (book.author.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.spacing4),
                child: Text(
                  book.author,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookCoverFallback extends StatelessWidget {
  const _BookCoverFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[AppColors.primary400, AppColors.primary600],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: const Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedBookOpen02,
          color: AppColors.card,
          size: 40,
        ),
      ),
    );
  }
}
