import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/library_entity.dart';
import '../cubit/library_details_cubit.dart';
import '../cubit/library_details_state.dart';
import '../models/library_details_navigation_data.dart';
import '../widgets/library_author_card.dart';
import '../widgets/library_book_card.dart';
import '../widgets/library_info_header.dart';

/// Library details screen bound to `/Libraries/{libraryId}/books`.
class LibraryDetailsScreen extends StatefulWidget {
  const LibraryDetailsScreen({super.key, this.library});

  final LibraryEntity? library;

  @override
  State<LibraryDetailsScreen> createState() => _LibraryDetailsScreenState();
}

class _LibraryDetailsScreenState extends State<LibraryDetailsScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.appCard,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 70,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.spacing24,
                    AppSpacing.spacing8,
                    AppSpacing.spacing24,
                    AppSpacing.spacing4,
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: context.back,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        icon: HugeIcon(
                          icon: context.isRTL
                              ? HugeIcons.strokeRoundedArrowRight01
                              : HugeIcons.strokeRoundedArrowLeft01,
                          color: foreground,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacing20),
                      Expanded(
                        child: Text(
                          widget.library?.libraryName ??
                              LocalizationConstants.libraryDetailsTitleKey.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h4.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _isFavorite = !_isFavorite),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 42,
                          height: 42,
                        ),
                        icon: Icon(
                          _isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: _isFavorite
                              ? const Color(0xFFFFC400)
                              : foreground,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: _LibraryDetailsView(library: widget.library)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryDetailsView extends StatefulWidget {
  const _LibraryDetailsView({required this.library});

  final LibraryEntity? library;

  @override
  State<_LibraryDetailsView> createState() => _LibraryDetailsViewState();
}

class _LibraryDetailsViewState extends State<_LibraryDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryDetailsCubit>().loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.appCard,
      child: BlocBuilder<LibraryDetailsCubit, LibraryDetailsState>(
        builder: (BuildContext context, LibraryDetailsState state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LibraryInfoHeader(library: widget.library),
                if (state.status == LibraryDetailsStatus.initial ||
                    (state.status == LibraryDetailsStatus.loading &&
                        state.books.isEmpty))
                  const _LibraryContentShimmer()
                else if (state.status == LibraryDetailsStatus.error &&
                    state.books.isEmpty)
                  _ErrorView(
                    message: state.errorMessage ??
                        LocalizationConstants.errorsUnknownMessageKey.tr(),
                    onRetry: () =>
                        context.read<LibraryDetailsCubit>().loadBooks(),
                  )
                else ...<Widget>[
                  if (state.authors.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.spacing28),
                    SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing26,
                        ),
                        itemCount: state.authors.length,
                        separatorBuilder: (separatorContext, separatorIndex) =>
                            const SizedBox(width: AppSpacing.spacing12),
                        itemBuilder: (BuildContext context, int index) {
                          final author = state.authors[index];
                          final works = state.books
                              .where((book) => book.author == author.name)
                              .toList(growable: false);
                          return LibraryAuthorCard(
                            author: author,
                            onTap: () => context.pushTo(
                              RouteNames.authorDetailsPath(author.name),
                              extra: AuthorDetailsNavigationData(
                                author: author,
                                works: works,
                                description: widget.library?.description ?? '',
                                rating: widget.library?.rating ?? 0,
                                reviewCount: widget.library?.reviewCount ?? 0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.spacing28),
                  _SectionTitle(
                    title: LocalizationConstants.libraryDetailsRecentlyAddedKey
                        .tr(),
                  ),
                  const SizedBox(height: AppSpacing.spacing10),
                  if (state.books.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing26,
                        vertical: AppSpacing.spacing24,
                      ),
                      child: Text(
                        LocalizationConstants.explorerEmptyMessageKey.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.appTextSecondary,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 205,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing26,
                        ),
                        itemCount: state.books.length,
                        separatorBuilder: (separatorContext, separatorIndex) =>
                            const SizedBox(width: AppSpacing.spacing8),
                        itemBuilder: (BuildContext context, int index) {
                          final book = state.books[index];
                          return LibraryDetailsBookCard(
                            book: book,
                            onTap: () => context.pushTo(
                              RouteNames.bookDetailsPath(
                                book.bookId,
                                book.listingId,
                              ),
                              extra: BookDetailsNavigationData(book: book),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing26),
      child: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LibraryContentShimmer extends StatelessWidget {
  const _LibraryContentShimmer();

  @override
  Widget build(BuildContext context) {
    final Color baseColor =
        context.isDark ? AppColors.outlineDark : AppColors.primary100;
    final Color highlightColor =
        context.isDark ? AppColors.surfaceDark : AppColors.primary50;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacing26,
          AppSpacing.spacing28,
          AppSpacing.spacing26,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _shimmerBox(height: 190)),
                const SizedBox(width: AppSpacing.spacing12),
                Expanded(child: _shimmerBox(height: 190)),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing28),
            _shimmerBox(width: 135, height: 22),
            const SizedBox(height: AppSpacing.spacing12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _shimmerBox(width: 90, height: 140),
                _shimmerBox(width: 90, height: 140),
                _shimmerBox(width: 90, height: 140),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _shimmerBox({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.radius10),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing24,
        AppSpacing.spacing40,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(LocalizationConstants.commonRetryKey.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
