import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../../libraries/libraries.dart';
import '../../domain/purchases.dart';
import '../purchases_cubit.dart';

class PurchasedBooksScreen extends StatelessWidget {
  const PurchasedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PurchasesCubit>(
      create: (_) => sl<PurchasesCubit>()..load(),
      child: const _PurchasedBooksView(),
    );
  }
}

class _PurchasedBooksView extends StatelessWidget {
  const _PurchasedBooksView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchasesCubit, PurchasesState>(
      listenWhen: (previous, current) => previous.error != current.error,
      listener: (BuildContext context, PurchasesState state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (BuildContext context, PurchasesState state) {
        return Scaffold(
          backgroundColor: context.appBackground,
          appBar: AppBar(
            backgroundColor: context.appBackground,
            surfaceTintColor: Colors.transparent,
            leading: context.canPop()
                ? IconButton(
                    onPressed: context.pop,
                    icon: Icon(
                      context.isRTL
                          ? Icons.arrow_forward_ios
                          : Icons.arrow_back_ios,
                    ),
                  )
                : null,
            title: Text('settings.library.myBooks'.tr()),
          ),
          body: RefreshIndicator(
            onRefresh: context.read<PurchasesCubit>().load,
            child: state.loading && state.books.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.books.isEmpty
                    ? ListView(
                        children: <Widget>[
                          const SizedBox(height: 180),
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 70,
                            color: AppColors.primary300,
                          ),
                          const SizedBox(height: 14),
                          Center(child: Text('purchases.empty'.tr())),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: .62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.books.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PurchasedBook book = state.books[index];
                          return _PurchasedBookCard(
                            book: book,
                            onTap: () => _openDetails(context, book),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }

  void _openDetails(BuildContext context, PurchasedBook book) {
    final LibraryBookEntity detailsBook = LibraryBookEntity(
      purchaseId: book.purchaseId,
      listingId: '',
      price: '',
      stock: '',
      condition: 0,
      bookId: book.bookId,
      title: book.title,
      author: book.author,
      description: book.description,
      coverImageUrl: book.coverImageUrl,
      language: book.language,
      isbn: book.isbn,
      categoryId: book.categoryId,
      categoryNameAr: '',
      categoryNameEn: '',
      format: book.digital ? 'Digital' : 'Physical',
    );
    context.pushTo(
      RouteNames.bookDetailsPath(book.bookId, book.purchaseId),
      extra: BookDetailsNavigationData(
        book: detailsBook,
        purchaseId: book.purchaseId,
      ),
    );
  }
}

class _PurchasedBookCard extends StatelessWidget {
  const _PurchasedBookCard({required this.book, required this.onTap});

  final PurchasedBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appCard,
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: book.coverImageUrl.isEmpty
                  ? const ColoredBox(
                      color: AppColors.primary100,
                      child: Icon(Icons.menu_book, size: 44),
                    )
                  : Image.network(
                      book.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.book),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.digital
                        ? 'purchases.read'.tr()
                        : 'purchases.physical'.tr(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
