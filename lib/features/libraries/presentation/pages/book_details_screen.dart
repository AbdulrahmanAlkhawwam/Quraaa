import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../book_assistant/book_assistant.dart';
import '../../../favorites/favorites.dart';
import '../../domain/entities/library_book_entity.dart';
import '../cubit/book_details_cubit.dart';
import '../cubit/book_details_state.dart';
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
    final BookDetailsState detailsState =
        context.watch<BookDetailsCubit>().state;
    final LibraryBookEntity? book = detailsState.book ?? widget.data?.book;
    final String title = _bookTitle(book);

    if (book == null && detailsState.status != BookDetailsStatus.success) {
      return _buildLoadState(context, detailsState);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: context.appCard,
        statusBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: context.appCard,
        systemNavigationBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.appCard,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BlocConsumer<FavoriteStatusCubit, FavoriteStatusState>(
                  bloc: _favoriteStatusCubit,
                  listenWhen: (FavoriteStatusState previous,
                          FavoriteStatusState current) =>
                      current.error != null && current.error != previous.error,
                  listener: (BuildContext context, FavoriteStatusState state) =>
                      context.showResolvedErrorSnackBar(state.error!),
                  builder: (BuildContext context, FavoriteStatusState state) {
                    return _BookHeader(
                      title: title,
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
                    horizontal: AppSpacing.spacing16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.spacing20),
                      _BookOverview(book: book, fallbackId: widget.bookId),
                      const SizedBox(height: AppSpacing.spacing14),
                      _BuyBookButton(
                        onPressed: () =>
                            BookPurchaseBottomSheet.show(context, book: book),
                      ),
                      const SizedBox(height: AppSpacing.spacing32),
                      _PreviewHeader(
                        onExpand: () => _showPreview(context, book, title),
                      ),
                      const SizedBox(height: AppSpacing.spacing10),
                      _BookPreview(book: book),
                      const SizedBox(height: AppSpacing.spacing28),
                      _ImportantPointsButton(
                        onPressed: () => _openImportantPoints(book),
                      ),
                      const SizedBox(height: AppSpacing.spacing28),
                      Text(
                        LocalizationConstants.libraryReviewsTitleKey.tr(),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: context.appTextPrimary,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing12),
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

  Widget _buildLoadState(
    BuildContext context,
    BookDetailsState detailsState,
  ) {
    final bool isLoading = detailsState.status == BookDetailsStatus.initial ||
        detailsState.status == BookDetailsStatus.loading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: context.appCard,
        statusBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: context.appCard,
        systemNavigationBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.appCard,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _BookHeader(
                title: widget.bookId,
                isFavorite: false,
                onBack: () => context.back(),
                onFavorite: null,
              ),
              Expanded(
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: context.isDark
                              ? AppColors.primary300
                              : AppColors.libraryGreen,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(AppSpacing.spacing24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                detailsState.errorMessage ??
                                    LocalizationConstants
                                        .errorsUnknownMessageKey
                                        .tr(),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.appTextSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.spacing16),
                              FilledButton(
                                onPressed: () =>
                                    context.read<BookDetailsCubit>().retry(),
                                child: Text(
                                  LocalizationConstants.commonRetryKey.tr(),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _bookTitle(LibraryBookEntity? book) {
    final String title = book?.title.trim() ?? '';
    return title.isNotEmpty ? title : widget.bookId;
  }

  void _openImportantPoints(LibraryBookEntity? book) {
    final String navigationPurchaseId = widget.data?.purchaseId?.trim() ?? '';
    final String bookPurchaseId = book?.purchaseId.trim() ?? '';
    final String purchaseId = navigationPurchaseId.isNotEmpty
        ? navigationPurchaseId
        : bookPurchaseId.isNotEmpty
            ? bookPurchaseId
            : widget.bookId.trim();
    final String title = _bookTitle(book);

    context.pushTo(
      RouteNames.bookAssistant,
      extra: BookAssistantNavigationData(
        purchaseId: purchaseId,
        question: LocalizationConstants.assistantBookImportantPointsQuestionKey
            .tr(namedArgs: <String, String>{'book': title}),
        book: AssistantBook(
          id: book?.bookId.trim().isNotEmpty ?? false
              ? book!.bookId
              : widget.bookId,
          title: title,
          author: book?.author ?? '',
          coverUrl: book?.coverImageUrl ?? '',
        ),
      ),
    );
  }

  void _showPreview(
    BuildContext context,
    LibraryBookEntity? book,
    String title,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.spacing16),
        backgroundColor: dialogContext.appCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: dialogContext.appTextPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing8),
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: _BookPreview(book: book, expanded: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({
    required this.title,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  final String title;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final Color color =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: HugeIcon(
                icon: context.isRTL
                    ? HugeIcons.strokeRoundedArrowRight01
                    : HugeIcons.strokeRoundedArrowLeft01,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.spacing20),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4.copyWith(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacing12),
            IconButton(
              onPressed: onFavorite,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? const Color(0xFFFFC400) : color,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookOverview extends StatelessWidget {
  const _BookOverview({required this.book, required this.fallbackId});

  final LibraryBookEntity? book;
  final String fallbackId;

  @override
  Widget build(BuildContext context) {
    final String title =
        book?.title.trim().isNotEmpty ?? false ? book!.title : fallbackId;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double coverWidth =
            ((constraints.maxWidth - AppSpacing.spacing14) * 0.34)
                .clamp(112.0, 150.0);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _BookCover(
                url: book?.coverImageUrl ?? '',
                width: coverWidth,
                height: coverWidth * 1.33,
              ),
            ),
            const SizedBox(width: AppSpacing.spacing14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: AppSpacing.spacing8,
                    runSpacing: AppSpacing.spacing4,
                    children: <Widget>[
                      if (book == null ||
                          book!.condition == 0 ||
                          book!.condition == 1)
                        _BookBadge(
                          label: LocalizationConstants.libraryBookNewKey.tr(),
                        ),
                      _BookBadge(
                        label: book?.format.trim().isNotEmpty ?? false
                            ? book!.format
                            : LocalizationConstants.libraryBookEbookKey.tr(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacing6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4.copyWith(
                      color: context.isDark
                          ? AppColors.primary300
                          : AppColors.libraryGreen,
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing6),
                  _MetadataLine(
                    label: LocalizationConstants.libraryBookLanguageKey.tr(),
                    value: book?.language ?? '',
                  ),
                  _MetadataLine(
                    label: LocalizationConstants.libraryBookPublisherKey.tr(),
                    value: _publisherValue(context),
                  ),
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
                  _MetadataLine(
                    label: LocalizationConstants.libraryBookVersionKey.tr(),
                    value: book?.version ?? '',
                  ),
                  _MetadataLine(
                    label: LocalizationConstants.libraryBookPriceKey.tr(),
                    value: _priceValue(book?.price ?? ''),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _publisherValue(BuildContext context) {
    final LibraryBookEntity? value = book;
    if (value == null) return '';
    if (value.publisher.trim().isNotEmpty) return value.publisher;
    if (context.locale.languageCode == 'ar' &&
        value.categoryNameAr.isNotEmpty) {
      return value.categoryNameAr;
    }
    return value.categoryNameEn;
  }

  String _priceValue(String rawPrice) {
    final String price = rawPrice.trim();
    if (price.isEmpty) return '';
    return price.contains(String.fromCharCode(36))
        ? price
        : <String>[price, String.fromCharCode(36)].join(' ');
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = ColoredBox(
      color: context.appSubtleSurface,
      child: Icon(
        Icons.menu_book_outlined,
        color: context.isDark ? AppColors.primary300 : AppColors.primary600,
        size: width * 0.3,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius10),
      child: SizedBox(
        width: width,
        height: height,
        child: url.trim().isEmpty
            ? placeholder
            : AppImage(
                url,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorWidget: placeholder,
              ),
      ),
    );
  }
}

class _BookBadge extends StatelessWidget {
  const _BookBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.spacing8,
        vertical: AppSpacing.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary400,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label : ${value.trim().isEmpty ? '-' : value}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color:
              context.isDark ? AppColors.primary300 : const Color(0xFF4F8C37),
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}

class _BuyBookButton extends StatelessWidget {
  const _BuyBookButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing28,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              LocalizationConstants.libraryBookBuyKey.tr(),
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.onExpand});

  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            LocalizationConstants.libraryBookPreviewKey.tr(),
            style: AppTextStyles.titleLarge.copyWith(
              color: context.appTextPrimary,
              fontSize: 17,
            ),
          ),
        ),
        IconButton(
          onPressed: onExpand,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          icon: Icon(
            Icons.fullscreen,
            color:
                context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _BookPreview extends StatelessWidget {
  const _BookPreview({required this.book, this.expanded = false});

  final LibraryBookEntity? book;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final List<String> pageUrls =
        book?.previewImageUrls.take(2).toList(growable: false) ??
            const <String>[];
    final double height = expanded ? 420 : 160;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double coverWidth = (constraints.maxWidth * 0.34).clamp(
            expanded ? 180.0 : 112.0,
            expanded ? 260.0 : 150.0,
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _BookCover(
                url: book?.coverImageUrl ?? '',
                width: coverWidth,
                height: height,
              ),
              const SizedBox(width: AppSpacing.spacing14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: _PreviewPage(
                          url: pageUrls.isNotEmpty ? pageUrls.first : '',
                          variant: 0,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: _PreviewPage(
                          url: pageUrls.length > 1 ? pageUrls[1] : '',
                          variant: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PreviewPage extends StatelessWidget {
  const _PreviewPage({required this.url, required this.variant});

  final String url;
  final int variant;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isNotEmpty) {
      return AppImage(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: _PreviewPagePlaceholder(variant: variant),
      );
    }
    return _PreviewPagePlaceholder(variant: variant);
  }
}

class _PreviewPagePlaceholder extends StatelessWidget {
  const _PreviewPagePlaceholder({required this.variant});

  final int variant;

  @override
  Widget build(BuildContext context) {
    final Color ink =
        variant == 0 ? const Color(0xFF345D9D) : const Color(0xFF7A326A);
    final Color accent =
        variant == 0 ? const Color(0xFFE6B33B) : const Color(0xFF8DCA77);

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(width: 42, height: 5, color: ink),
            const SizedBox(height: 5),
            ...List<Widget>.generate(
              4,
              (int index) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Container(
                  width: index.isEven ? double.infinity : 48,
                  height: 2,
                  color: const Color(0xFFB8B8B8),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.28),
                  border: Border.all(color: accent),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 12,
                      child: Container(height: 5, color: ink),
                    ),
                    Positioned(
                      left: 8,
                      right: 20,
                      top: 24,
                      child: Container(
                        height: 3,
                        color: ink.withValues(alpha: 0.55),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Icon(
                        variant == 0 ? Icons.public : Icons.family_restroom,
                        color: ink,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(width: double.infinity, height: 2, color: Colors.black26),
            const SizedBox(height: 3),
            Container(width: 54, height: 2, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _ImportantPointsButton extends StatelessWidget {
  const _ImportantPointsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color color =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: context.isDark ? AppColors.primary700 : AppColors.primary200,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing20,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _AiPointsIcon(color: color),
            const SizedBox(width: AppSpacing.spacing12),
            Flexible(
              child: Text(
                LocalizationConstants.libraryBookImportantPointsKey.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4.copyWith(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiPointsIcon extends StatelessWidget {
  const _AiPointsIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          PositionedDirectional(
            start: 0,
            bottom: 0,
            child: Icon(Icons.psychology_outlined, color: color, size: 27),
          ),
          PositionedDirectional(
            end: -1,
            top: -1,
            child: Icon(Icons.auto_awesome, color: color, size: 12),
          ),
        ],
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
