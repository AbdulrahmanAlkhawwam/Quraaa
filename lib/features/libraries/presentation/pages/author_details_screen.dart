import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/library_book_entity.dart';
import '../cubit/library_details_state.dart';
import '../models/library_details_navigation_data.dart';
import '../models/library_review_view_model.dart';
import '../widgets/library_review_card.dart';

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({super.key, required this.authorName, this.data});

  final String authorName;
  final AuthorDetailsNavigationData? data;

  @override
  Widget build(BuildContext context) {
    final LibraryAuthorViewModel author =
        data?.author ?? LibraryAuthorViewModel(name: authorName, imageUrl: '');
    final String description = data?.description.trim().isNotEmpty ?? false
        ? data!.description.trim()
        : LocalizationConstants.libraryDetailsDefaultDescriptionKey.tr();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.appCard,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _BackHeader(onBack: context.back),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.spacing20),
                      _AuthorIdentity(author: author),
                      const SizedBox(height: AppSpacing.spacing20),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF53664A),
                          height: 1.34,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing10),
                      _RatingRow(
                        rating: data?.rating ?? 0,
                        reviewCount: data?.reviewCount ?? 0,
                      ),
                      const SizedBox(height: AppSpacing.spacing20),
                      Text(
                        LocalizationConstants.libraryAuthorWorksKey.tr(),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: context.isDark
                              ? AppColors.primary300
                              : AppColors.libraryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing10),
                _AuthorWorks(works: data?.works ?? const <LibraryBookEntity>[]),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.spacing20),
                      Text(
                        LocalizationConstants.libraryReviewsTitleKey.tr(),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: context.isDark
                              ? AppColors.primary300
                              : AppColors.libraryGreen,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing10),
                      LibraryReviewCard(review: _previewReview(context, 3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackHeader extends StatelessWidget {
  const _BackHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.spacing20,
          ),
          child: IconButton(
            onPressed: onBack,
            icon: HugeIcon(
              icon: context.isRTL
                  ? HugeIcons.strokeRoundedArrowRight01
                  : HugeIcons.strokeRoundedArrowLeft01,
              color: context.isDark
                  ? AppColors.primary300
                  : AppColors.libraryGreen,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorIdentity extends StatelessWidget {
  const _AuthorIdentity({required this.author});

  final LibraryAuthorViewModel author;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClipOval(
          child: SizedBox(
            width: 76,
            height: 76,
            child: author.imageUrl.isNotEmpty
                ? AppImage(
                    author.imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorWidget: _authorPlaceholder(context),
                  )
                : _authorPlaceholder(context),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                author.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge.copyWith(
                  color: context.isDark
                      ? AppColors.primary300
                      : AppColors.libraryGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing4),
              Text(
                LocalizationConstants.libraryAuthorWriterKey.tr(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.appTextSecondary,
                ),
              ),
              if (author.subtitle.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.spacing4),
                Text(
                  author.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _authorPlaceholder(BuildContext context) {
    return ColoredBox(
      color: context.appSubtleSurface,
      child: Icon(
        Icons.person_outline,
        size: 40,
        color: context.isDark ? AppColors.primary300 : AppColors.primary600,
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ...List<Widget>.generate(5, (int index) {
          return Icon(
            index < rating.clamp(0, 5).round()
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFFFC400),
            size: 20,
          );
        }),
        const SizedBox(width: AppSpacing.spacing10),
        Text(
          '$reviewCount ${LocalizationConstants.libraryDetailsReviewersKey.tr()}',
          style: AppTextStyles.bodySmall.copyWith(
            color: context.appTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _AuthorWorks extends StatelessWidget {
  const _AuthorWorks({required this.works});

  final List<LibraryBookEntity> works;

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return const SizedBox(height: 125);
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing20),
        itemCount: works.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.spacing14),
        itemBuilder: (BuildContext context, int index) {
          final LibraryBookEntity book = works[index];
          return SizedBox(
            width: 116,
            child: GestureDetector(
              onTap: () => context.pushTo(
                RouteNames.bookDetailsPath(book.bookId, book.listingId),
                extra: BookDetailsNavigationData(book: book),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radius4),
                      child: SizedBox(
                        width: 64,
                        height: 96,
                        child: book.coverImageUrl.isNotEmpty
                            ? AppImage(
                                book.coverImageUrl,
                                width: 64,
                                height: 96,
                                fit: BoxFit.cover,
                              )
                            : const ColoredBox(
                                color: AppColors.primary100,
                                child: Icon(Icons.book_outlined),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing8),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.appTextPrimary,
                    ),
                  ),
                  Text(
                    _bookSubtitle(context, book),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _bookSubtitle(BuildContext context, LibraryBookEntity book) {
    if (context.locale.languageCode == 'ar' && book.categoryNameAr.isNotEmpty) {
      return book.categoryNameAr;
    }
    if (book.categoryNameEn.isNotEmpty) return book.categoryNameEn;
    return book.language;
  }
}

LibraryReviewViewModel _previewReview(BuildContext context, int rating) {
  return LibraryReviewViewModel(
    rating: rating,
    comment: LocalizationConstants.libraryReviewsPreviewCommentKey.tr(),
    reviewerName: LocalizationConstants.libraryReviewsPreviewUserKey.tr(),
  );
}
