import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    required this.book,
    required this.onTap,
    super.key,
  });

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: book.title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(
                color: context.isDark
                    ? AppColors.surfaceDark
                    : AppColors.primary900,
              ),
              AppImage(
                book.displayCover,
                fit: BoxFit.cover,
                errorWidget: const _BookCoverFallback(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0, -0.25),
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Color(0x1A000000),
                      Color(0xC7000000),
                    ],
                    stops: <double>[0, 0.55, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (book.format == BookFormat.audio)
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: _FormatBadge(
                          label: LocalizationConstants.booksCatalogSoundBookKey
                              .tr(),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.12,
                      ),
                    ),
                    if (book.subtitle.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 1),
                      Text(
                        book.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _displayPrice(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius4),
                          ),
                          child: Text(
                            LocalizationConstants.booksCatalogViewKey.tr(),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayPrice(BuildContext context) {
    if (book.format == BookFormat.free) {
      return LocalizationConstants.booksCatalogFreeBookKey.tr();
    }
    final String price = book.price.trim();
    if (price.isEmpty) return '-';
    final String currency = String.fromCharCode(36);
    return price.contains(currency) ? price : '$price$currency';
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(AppRadius.radius24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCoverFallback extends StatelessWidget {
  const _BookCoverFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary900,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Colors.white.withValues(alpha: 0.72),
          size: 48,
        ),
      ),
    );
  }
}
