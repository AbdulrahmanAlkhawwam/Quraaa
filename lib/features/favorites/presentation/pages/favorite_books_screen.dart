import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../libraries/libraries.dart';
import '../../domain/entities/favorite_book.dart';
import '../cubit/favorite_books_cubit.dart';

class FavoriteBooksScreen extends StatelessWidget {
  const FavoriteBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoriteBooksCubit>(
      create: (_) => sl<FavoriteBooksCubit>()..load(),
      child: Scaffold(
        backgroundColor: context.appCard,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _Header(onBack: context.back),
              Expanded(
                child: BlocBuilder<FavoriteBooksCubit, FavoriteBooksState>(
                  builder: (BuildContext context, FavoriteBooksState state) {
                    return switch (state) {
                      FavoriteBooksInitial() ||
                      FavoriteBooksLoading() => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary600,
                        ),
                      ),
                      FavoriteBooksFailure(message: final message) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.spacing24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error500,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.spacing12),
                              TextButton(
                                onPressed: context
                                    .read<FavoriteBooksCubit>()
                                    .load,
                                child: Text(
                                  LocalizationConstants.favoritesRetryKey.tr(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FavoriteBooksLoaded(items: final items)
                          when items.isEmpty =>
                        Center(
                          child: Text(
                            LocalizationConstants.favoritesEmptyKey.tr(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.appTextSecondary,
                            ),
                          ),
                        ),
                      FavoriteBooksLoaded(items: final items) =>
                        ListView.separated(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.spacing20,
                            AppSpacing.spacing8,
                            AppSpacing.spacing20,
                            AppSpacing.spacing24,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(
                            color: context.appBorder,
                            height: AppSpacing.spacing20,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final FavoriteBook item = items[index];
                            return _FavoriteTile(
                              item: item,
                              onRemove: () => context
                                  .read<FavoriteBooksCubit>()
                                  .remove(item.bookId),
                              onTap: () => _openBook(context, item),
                            );
                          },
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBook(BuildContext context, FavoriteBook item) {
    final LibraryBookEntity book = LibraryBookEntity(
      listingId: '',
      price: '0',
      stock: '0',
      condition: 0,
      bookId: item.bookId,
      title: item.title,
      author: item.author,
      description: item.description,
      coverImageUrl: item.coverImageUrl,
      language: item.language,
      isbn: item.isbn,
      categoryId: item.categoryId,
      categoryNameAr: '',
      categoryNameEn: '',
    );
    context.pushTo(
      RouteNames.bookDetailsPath(item.bookId),
      extra: BookDetailsNavigationData(book: book),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing12),
      child: SizedBox(
        height: 64,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              icon: HugeIcon(
                icon: context.isRTL
                    ? HugeIcons.strokeRoundedArrowRight01
                    : HugeIcons.strokeRoundedArrowLeft01,
                color: context.isDark
                    ? AppColors.primary300
                    : AppColors.libraryGreen,
                size: 23,
              ),
            ),
            const SizedBox(width: AppSpacing.spacing8),
            Text(
              LocalizationConstants.favoritesTitleKey.tr(),
              style: AppTextStyles.titleLarge.copyWith(
                color: context.appTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final FavoriteBook item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing4),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius8),
              child: SizedBox(
                width: 58,
                height: 84,
                child: item.coverImageUrl.isEmpty
                    ? ColoredBox(
                        color: context.appSubtleSurface,
                        child: const Icon(Icons.book_outlined),
                      )
                    : AppImage(
                        item.coverImageUrl,
                        width: 58,
                        height: 84,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacing14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title.isEmpty
                        ? LocalizationConstants.favoritesBookFallbackKey.tr()
                        : item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.author.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.spacing6),
                    Text(
                      item.author,
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
            IconButton(
              tooltip: LocalizationConstants.favoritesRemoveKey.tr(),
              onPressed: onRemove,
              icon: const Icon(Icons.star_rounded, color: Color(0xFFFFC400)),
            ),
          ],
        ),
      ),
    );
  }
}
