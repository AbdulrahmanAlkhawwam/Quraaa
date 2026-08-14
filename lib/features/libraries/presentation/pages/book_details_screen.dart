import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../../favorites/favorites.dart';
import '../../domain/entities/library_book_entity.dart';
import '../cubit/library_details_state.dart';
import '../models/library_details_navigation_data.dart';
import '../models/library_review_view_model.dart';
import '../widgets/book_purchase_bottom_sheet.dart';
import '../widgets/library_review_card.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, required this.bookId, this.data});

  final String bookId;
  final BookDetailsNavigationData? data;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late final FavoriteStatusCubit _favoriteStatusCubit;

  @override
  void initState() {
    super.initState();
    _favoriteStatusCubit = sl<FavoriteStatusCubit>()..load(widget.bookId);
  }

  @override
  void dispose() {
    _favoriteStatusCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LibraryBookEntity? book = widget.data?.book;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.appCard,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BlocConsumer<FavoriteStatusCubit, FavoriteStatusState>(
                  bloc: _favoriteStatusCubit,
                  listenWhen: (previous, current) =>
                      current.error != null && current.error != previous.error,
                  listener: (BuildContext context, FavoriteStatusState state) {
                    context.showResolvedErrorSnackBar(state.error!);
                  },
                  builder: (BuildContext context, FavoriteStatusState state) {
                    return _BookHeader(
                      isFavorite: state.isFavorite,
                      onBack: () => context.back(),
                      onFavorite: state.isLoading
                          ? null
                          : () => _favoriteStatusCubit.toggle(widget.bookId),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.spacing20),
                      _BookSummary(book: book, fallbackId: widget.bookId),
                      const SizedBox(height: AppSpacing.spacing24),
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
                      const SizedBox(height: AppSpacing.spacing12),
                      LibraryReviewCard(review: _previewReview(context, 5)),
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

class _BookHeader extends StatelessWidget {
  const _BookHeader({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final Color foreground = context.isDark
        ? AppColors.primary300
        : AppColors.libraryGreen;

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              icon: HugeIcon(
                icon: context.isRTL
                    ? HugeIcons.strokeRoundedArrowRight01
                    : HugeIcons.strokeRoundedArrowLeft01,
                color: foreground,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? const Color(0xFFFFC400) : foreground,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookSummary extends StatelessWidget {
  const _BookSummary({required this.book, required this.fallbackId});

  final LibraryBookEntity? book;
  final String fallbackId;

  @override
  Widget build(BuildContext context) {
    final String title = book?.title.trim().isNotEmpty ?? false
        ? book!.title
        : fallbackId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius4),
          child: SizedBox(
            width: 108,
            height: 162,
            child: book?.coverImageUrl.isNotEmpty ?? false
                ? AppImage(
                    book!.coverImageUrl,
                    width: 108,
                    height: 162,
                    fit: BoxFit.cover,
                  )
                : ColoredBox(
                    color: context.appSubtleSurface,
                    child: Icon(
                      Icons.book_outlined,
                      color: context.isDark
                          ? AppColors.primary300
                          : AppColors.primary600,
                      size: 38,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.spacing6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: context.isDark
                        ? AppColors.primary300
                        : AppColors.libraryGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing4),
                _MetadataLine(
                  label: LocalizationConstants.libraryBookPublisherKey.tr(),
                  value: _publisherValue(context),
                ),
                const SizedBox(height: AppSpacing.spacing4),
                GestureDetector(
                  onTap: book == null || book!.author.isEmpty
                      ? null
                      : () => context.pushTo(
                          RouteNames.authorDetailsPath(book!.author),
                          extra: AuthorDetailsNavigationData(
                            author: LibraryAuthorViewModel(
                              name: book!.author,
                              imageUrl: '',
                            ),
                            works: <LibraryBookEntity>[book!],
                            description: book!.description,
                          ),
                        ),
                  child: _MetadataLine(
                    label: LocalizationConstants.libraryBookWriterKey.tr(),
                    value: book?.author ?? '',
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing4),
                _MetadataLine(
                  label: LocalizationConstants.libraryBookLanguageKey.tr(),
                  value: book?.language ?? '',
                ),
                const SizedBox(height: AppSpacing.spacing12),
                SizedBox(
                  height: 38,
                  child: FilledButton(
                    onPressed: () =>
                        BookPurchaseBottomSheet.show(context, book: book),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
                      ),
                    ),
                    child: Text(
                      LocalizationConstants.libraryBookBuyKey.tr(),
                      style: AppTextStyles.buttonSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _publisherValue(BuildContext context) {
    if (book == null) return '';
    if (context.locale.languageCode == 'ar' &&
        book!.categoryNameAr.isNotEmpty) {
      return book!.categoryNameAr;
    }
    if (book!.categoryNameEn.isNotEmpty) return book!.categoryNameEn;
    return '';
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: ${value.isEmpty ? '-' : value}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodySmall.copyWith(
        color: context.isDark ? AppColors.primary300 : const Color(0xFF68A94A),
      ),
    );
  }
}

LibraryReviewViewModel _previewReview(BuildContext context, int rating) {
  return LibraryReviewViewModel(
    rating: rating,
    comment: LocalizationConstants.libraryReviewsPreviewCommentKey.tr(),
    reviewerName: LocalizationConstants.libraryReviewsPreviewUserKey.tr(),
  );
}
