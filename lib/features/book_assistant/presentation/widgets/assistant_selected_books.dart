import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/assistant_book.dart';

class AssistantSelectedBooks extends StatelessWidget {
  const AssistantSelectedBooks({
    required this.books,
    required this.scale,
    super.key,
  });

  final List<AssistantBook> books;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8 * scale,
      runSpacing: 8 * scale,
      children: books.map((AssistantBook book) {
        return Container(
          constraints: BoxConstraints(maxWidth: 150 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 10 * scale,
            vertical: 6 * scale,
          ),
          decoration: BoxDecoration(
            color: context.appSubtleSurface,
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(color: context.appBorder),
          ),
          child: Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: context.isDark ? AppColors.primary300 : AppColors.primary700,
              fontSize: 12 * scale,
              height: 1.1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
