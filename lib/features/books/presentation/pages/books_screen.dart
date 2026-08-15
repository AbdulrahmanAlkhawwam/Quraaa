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
import '../bloc/books_bloc.dart';
import '../widgets/book_card.dart';
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

  void _showFilterSheet(BuildContext context) {
    final BooksBloc bloc = context.read<BooksBloc>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.appCard,
      builder: (BuildContext sheetContext) {
        return BlocProvider<BooksBloc>.value(
          value: bloc,
          child: const _BooksFilterSheet(),
        );
      },
    );
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
      bookId: book.id,
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
      RouteNames.bookDetailsPath(book.id),
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

class _BooksFilterSheet extends StatelessWidget {
  const _BooksFilterSheet();

  @override
  Widget build(BuildContext context) {
    final BookFormat? selected = context.watch<BooksBloc>().state.format;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                LocalizationConstants.booksCatalogFilterTitleKey.tr(),
                style: AppTextStyles.titleLarge.copyWith(
                  color: context.appTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            ...BookFormat.values.map(
              (BookFormat format) => ListTile(
                key: ValueKey<String>('books_filter_${format.name}'),
                title: Text(_formatLabel(format)),
                leading: Icon(
                  selected == format
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected == format
                      ? AppColors.primary600
                      : context.appTextSecondary,
                ),
                onTap: () {
                  context.read<BooksBloc>().add(BooksFilterChanged(format));
                  Navigator.pop(context);
                },
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<BooksBloc>().add(
                      const BooksFilterChanged(null),
                    );
                Navigator.pop(context);
              },
              child: Text(
                LocalizationConstants.booksCatalogClearFilterKey.tr(),
              ),
            ),
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
