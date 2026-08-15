import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class BooksSearchBar extends StatelessWidget {
  const BooksSearchBar({
    required this.onChanged,
    required this.onFilterPressed,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        context.isDark ? AppColors.primary300 : AppColors.primary600;

    return Container(
      height: 56,
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.spacing18,
        end: AppSpacing.spacing8,
      ),
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search_rounded, color: foreground, size: 28),
          const SizedBox(width: AppSpacing.spacing12),
          Expanded(
            child: TextField(
              key: const Key('books_search_field'),
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyLarge.copyWith(
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: LocalizationConstants.booksCatalogSearchHintKey.tr(),
                filled: false,
                fillColor: Colors.transparent,
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            key: const Key('books_filter_button'),
            tooltip: LocalizationConstants.booksCatalogFilterTitleKey.tr(),
            onPressed: onFilterPressed,
            icon: Icon(
              Icons.filter_alt_outlined,
              color: foreground,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
