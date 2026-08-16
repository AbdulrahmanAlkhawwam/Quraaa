import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/home_book_entity.dart';
import 'home_book_card.dart';
import 'home_section_shimmer.dart';

/// A horizontally scrolling section of books (e.g. Recommended, Note).
class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    required this.books,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onBookTap,
  });

  final String title;
  final List<HomeBookEntity> books;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final ValueChanged<HomeBookEntity>? onBookTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isLoading && errorMessage == null)
                Text(
                  '${books.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextTertiary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacing12),
        if (isLoading)
          const HomeSectionShimmer()
        else if (errorMessage != null)
          _HomeSectionMessage(
            message: LocalizationConstants.homeBooksLoadFailedKey.tr(),
            onRetry: onRetry,
          )
        else if (books.isEmpty)
          _HomeSectionMessage(
            message: LocalizationConstants.homeBooksEmptyKey.tr(),
          )
        else
          SizedBox(
            height: 276,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing16,
              ),
              itemCount: books.length,
              separatorBuilder: (separatorContext, separatorIndex) =>
                  const SizedBox(width: AppSpacing.spacing16),
              itemBuilder: (BuildContext context, int index) {
                final HomeBookEntity book = books[index];
                return HomeBookCard(
                  book: book,
                  onTap: () => onBookTap?.call(book),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _HomeSectionMessage extends StatelessWidget {
  const _HomeSectionMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(LocalizationConstants.commonRetryKey.tr()),
              ),
          ],
        ),
      ),
    );
  }
}
