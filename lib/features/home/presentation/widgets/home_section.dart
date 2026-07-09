import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../models/home_book.dart';
import 'home_book_card.dart';

/// A horizontally scrolling section of books (e.g. Recommended, Note).
class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    required this.totalSize,
    required this.books,
    this.onBookTap,
  });

  final String title;
  final String totalSize;
  final List<HomeBook> books;
  final ValueChanged<HomeBook>? onBookTap;

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
              Text(
                totalSize,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.appTextTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacing12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
            ),
            itemCount: books.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.spacing16),
            itemBuilder: (BuildContext context, int index) {
              final HomeBook book = books[index];
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
