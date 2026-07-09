import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/assistant_book.dart';

class AssistantBookPickerSheet extends StatelessWidget {
  const AssistantBookPickerSheet({
    required this.books,
    required this.selectedBooks,
    required this.onBookToggled,
    super.key,
  });

  final List<AssistantBook> books;
  final List<AssistantBook> selectedBooks;
  final ValueChanged<AssistantBook> onBookToggled;

  @override
  Widget build(BuildContext context) {
    final double scale = context.compactFeatureScale;
    final Color titleColor =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          22 * scale,
          18 * scale,
          22 * scale,
          18 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocalizationConstants.assistantPickerTitleKey.tr(),
              style: AppTextStyles.h4.copyWith(
                color: titleColor,
                fontSize: 22 * scale,
                height: 1.1,
              ),
            ),
            SizedBox(height: 14 * scale),
            ...books.map((AssistantBook book) {
              final bool selected = selectedBooks.contains(book);
              return _BookPickerTile(
                book: book,
                selected: selected,
                scale: scale,
                onTap: () => onBookToggled(book),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BookPickerTile extends StatelessWidget {
  const _BookPickerTile({
    required this.book,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final AssistantBook book;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color titleColor =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;

    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18 * scale),
        child: Container(
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: selected ? context.appSubtleSurface : context.appCard,
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color: selected ? AppColors.primary300 : context.appBorder,
            ),
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10 * scale),
                child: SizedBox(
                  width: 42 * scale,
                  height: 56 * scale,
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) {
                      return const ColoredBox(color: AppColors.primary100);
                    },
                    errorWidget: (
                      BuildContext context,
                      String url,
                      Object error,
                    ) {
                      return const ColoredBox(color: AppColors.primary100);
                    },
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: titleColor,
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: context.appTextSecondary,
                        fontSize: 12 * scale,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10 * scale),
              HugeIcon(
                icon: selected
                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                    : HugeIcons.strokeRoundedAddCircle,
                color: selected ? AppColors.primary600 : AppColors.primary300,
                size: 24 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
