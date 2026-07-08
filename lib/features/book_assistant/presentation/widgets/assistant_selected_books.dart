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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
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
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(18 * scale),
              border: Border.all(color: AppColors.primary100),
            ),
            child: Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary700,
                fontSize: 12 * scale,
                height: 1.1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
