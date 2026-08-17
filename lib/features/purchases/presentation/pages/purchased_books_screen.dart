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
      listenWhen: (PurchasesState previous, PurchasesState current) =>
          previous.error != current.error ||
          previous.openSerial != current.openSerial,
      listener: (BuildContext context, PurchasesState state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
          return;
        }
        if (state.openSerial > 0 &&
            state.openedPurchaseId?.trim().isNotEmpty == true) {
          final String route = '${RouteNames.pdfReader}'
              '?purchaseId=${Uri.encodeQueryComponent(state.openedPurchaseId!)}'
              '&name=${Uri.encodeQueryComponent(state.openedName ?? 'PDF')}';
          context.pushTo(route);
        }
      },
      builder: (BuildContext context, PurchasesState state) {
        final PurchasesCubit cubit = context.read<PurchasesCubit>();
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
            title: Text('settings.library.downloads'.tr()),
          ),
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: state.loading && state.books.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.books.isEmpty
                    ? ListView(
                        children: <Widget>[
                          const SizedBox(height: 180),
                          Icon(
                            Icons.download_done_outlined,
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
                          childAspectRatio: .53,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.books.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PurchasedBook book = state.books[index];
                          final bool offline = state.isOffline(book);
                          final bool downloading = state.isDownloading(book);
                          return _PurchasedBookCard(
                            book: book,
                            offline: offline,
                            downloading: downloading,
                            onTap: () => _openDetails(context, book),
                            onDownload: () => cubit.download(book),
                            onRead: () => cubit.open(book),
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
  const _PurchasedBookCard({
    required this.book,
    required this.offline,
    required this.downloading,
    required this.onTap,
    required this.onDownload,
    required this.onRead,
  });

  final PurchasedBook book;
  final bool offline;
  final bool downloading;
  final VoidCallback onTap;
  final Future<bool> Function() onDownload;
  final VoidCallback onRead;

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
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: AppColors.primary100,
                        child: Icon(Icons.book),
                      ),
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
                  const SizedBox(height: 5),
                  if (!book.digital)
                    Text(
                      'purchases.physical'.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.appTextSecondary,
                      ),
                    )
                  else ...<Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          offline
                              ? Icons.offline_pin_outlined
                              : Icons.cloud_download_outlined,
                          size: 16,
                          color: offline
                              ? AppColors.primary600
                              : context.appTextSecondary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            offline
                                ? 'purchases.offline_copy'.tr()
                                : 'purchases.online_only'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: offline
                                  ? AppColors.primary600
                                  : context.appTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: offline
                          ? FilledButton.icon(
                              onPressed: onRead,
                              icon: const Icon(Icons.menu_book_outlined,
                                  size: 17),
                              label: Text('purchases.read'.tr()),
                            )
                          : OutlinedButton.icon(
                              onPressed: downloading ? null : onDownload,
                              icon: downloading
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download_outlined,
                                      size: 17),
                              label: Text(
                                downloading
                                    ? 'purchases.downloading'.tr()
                                    : 'purchases.download'.tr(),
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
