import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../home/home.dart';
import '../../../libraries/libraries.dart';
import '../../../settings/settings.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_catalog_filter.dart';
import '../bloc/books_bloc.dart';
import '../widgets/book_card.dart';
import '../widgets/books_filter_sheet.dart';
import '../widgets/books_search_bar.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget books = BlocProvider<BooksBloc>(
      create: (_) => sl<BooksBloc>()..add(const BooksRequested()),
      child: const _BooksView(),
    );
    if (!sl.isRegistered<LibraryRegistrationCubit>()) return books;

    return BlocProvider<LibraryRegistrationCubit>(
      create: (_) => sl<LibraryRegistrationCubit>(),
      child: LibraryRegistrationListener(child: books),
    );
  }
}

class _BooksView extends StatelessWidget {
  const _BooksView();

  @override
  Widget build(BuildContext context) {
    final UserContextSnapshot user = sl.isRegistered<UserContextProvider>()
        ? sl<UserContextProvider>().snapshot
        : const UserContextSnapshot(subscriptionStatus: 'active');
    final bool isGuest = user.subscriptionStatus != 'active';

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: HomeAppBar(
        firstName: user.userName ?? '',
        isGuest: isGuest,
      ),
      backgroundColor: context.isDark ? context.appBackground : Colors.white,
      bottomNavigationBar: HomeBottomNav(
        currentIndex: 2,
        isGuest: isGuest,
        onTap: (_, String route) {
          if (route != RouteNames.userBooks) context.goTo(route);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: BooksSearchBar(
                onChanged: (String value) =>
                    context.read<BooksBloc>().add(BooksQueryChanged(value)),
                onFilterPressed: () => _showFilterSheet(context),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing10),
            const BooksFormatFilters(),
            const SizedBox(height: AppSpacing.spacing10),
            const Expanded(child: _CatalogBody()),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final BooksBloc bloc = context.read<BooksBloc>();
    final BookCatalogFilter? filter =
        await showModalBottomSheet<BookCatalogFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        duration: Duration(milliseconds: 340),
        reverseDuration: Duration(milliseconds: 280),
      ),
      builder: (BuildContext sheetContext) {
        return BlocProvider<BooksBloc>.value(
          value: bloc,
          child: BooksFilterSheet(initialFilter: bloc.state.catalogFilter),
        );
      },
    );
    if (filter != null && context.mounted) {
      bloc.add(BooksCatalogFilterApplied(filter));
    }
  }
}

class BooksFormatFilters extends StatelessWidget {
  const BooksFormatFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final BookFormat? selected = context.select(
      (BooksBloc bloc) => bloc.state.format,
    );

    return SizedBox(
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: BookFormat.values.map((BookFormat format) {
            final bool isSelected = selected == format;
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                end: AppSpacing.spacing8,
              ),
              child: OutlinedButton(
                onPressed: () => context.read<BooksBloc>().add(
                      BooksFilterChanged(isSelected ? null : format),
                    ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  foregroundColor: isSelected
                      ? Colors.white
                      : context.isDark
                          ? AppColors.primary300
                          : AppColors.primary600,
                  backgroundColor:
                      isSelected ? AppColors.primary600 : Colors.transparent,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary600
                        : context.isDark
                            ? AppColors.primary700
                            : AppColors.primary200,
                  ),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  _formatLabel(format),
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BooksBloc, BooksState>(
      builder: (BuildContext context, BooksState state) {
        return switch (state.status) {
          BooksStatus.initial ||
          BooksStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          BooksStatus.failure => _CatalogMessage(
              message: LocalizationConstants.booksCatalogLoadFailedKey.tr(),
              actionLabel: LocalizationConstants.booksCatalogRetryKey.tr(),
              onAction: () =>
                  context.read<BooksBloc>().add(const BooksRequested()),
            ),
          BooksStatus.success when state.books.isEmpty => _CatalogMessage(
              message: LocalizationConstants.booksCatalogEmptyKey.tr(),
            ),
          BooksStatus.success => RefreshIndicator(
              onRefresh: () async {
                final BooksBloc bloc = context.read<BooksBloc>()
                  ..add(const BooksRequested());
                await bloc.stream.firstWhere(
                  (BooksState value) => value.status != BooksStatus.loading,
                );
              },
              child: GridView.builder(
                key: const Key('books_catalog_grid'),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 122),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 22,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.71,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final Book book = state.books[index];
                  return BookCard(
                    book: book,
                    onTap: () => _openBookDetails(context, book),
                  );
                },
              ),
            ),
        };
      },
    );
  }

  void _openBookDetails(BuildContext context, Book book) {
    final LibraryBookEntity detailsBook = LibraryBookEntity(
      listingId: book.listingId,
      price: book.price,
      stock: '',
      condition: book.condition ?? 0,
      bookId: book.id == book.listingId ? '' : book.id,
      title: book.title,
      author: book.author,
      description: book.description,
      coverImageUrl: book.coverImageUrl,
      language: book.language,
      isbn: book.isbn,
      categoryId: book.categoryId,
      categoryNameAr: '',
      categoryNameEn: '',
      publisher: book.publisher,
      version: book.version,
      format: _formatLabel(book.format),
      previewImageUrls: book.previewImageUrls,
    );

    context.pushTo(
      RouteNames.bookDetailsPath(
        book.listingId.isNotEmpty ? book.listingId : book.id,
      ),
      extra: BookDetailsNavigationData(book: detailsBook),
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: context.appTextSecondary,
            ),
            const SizedBox(height: AppSpacing.spacing12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.spacing12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatLabel(BookFormat format) {
  return switch (format) {
    BookFormat.audio => LocalizationConstants.booksCatalogSoundBookKey.tr(),
    BookFormat.ebook => LocalizationConstants.booksCatalogEbookKey.tr(),
    BookFormat.free => LocalizationConstants.booksCatalogFreeBookKey.tr(),
    BookFormat.used => LocalizationConstants.booksCatalogUsedBookKey.tr(),
  };
}
