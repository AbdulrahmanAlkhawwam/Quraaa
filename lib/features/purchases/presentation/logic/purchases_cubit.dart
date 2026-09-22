import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/purchased_book.dart';
import '../../domain/use_cases/download_purchase_for_offline_use_case.dart';
import '../../domain/use_cases/get_purchased_books_use_case.dart';
import '../../domain/use_cases/is_purchase_available_offline_use_case.dart';

class PurchasesState extends Equatable {
  const PurchasesState({
    this.loading = false,
    this.books = const <PurchasedBook>[],
    this.offlinePurchaseIds = const <String>{},
    this.downloadingPurchaseIds = const <String>{},
    this.error,
    this.openedName,
    this.openedPurchaseId,
    this.openSerial = 0,
  });

  final bool loading;
  final List<PurchasedBook> books;
  final Set<String> offlinePurchaseIds;
  final Set<String> downloadingPurchaseIds;
  final String? error;
  final String? openedName;
  final String? openedPurchaseId;
  final int openSerial;

  bool isOffline(PurchasedBook book) =>
      offlinePurchaseIds.contains(book.purchaseId);
  bool isDownloading(PurchasedBook book) =>
      downloadingPurchaseIds.contains(book.purchaseId);

  PurchasesState copyWith({
    bool? loading,
    List<PurchasedBook>? books,
    Set<String>? offlinePurchaseIds,
    Set<String>? downloadingPurchaseIds,
    String? error,
    bool clearError = false,
    String? openedName,
    String? openedPurchaseId,
    int? openSerial,
  }) {
    return PurchasesState(
      loading: loading ?? this.loading,
      books: books ?? this.books,
      offlinePurchaseIds: offlinePurchaseIds ?? this.offlinePurchaseIds,
      downloadingPurchaseIds:
          downloadingPurchaseIds ?? this.downloadingPurchaseIds,
      error: clearError ? null : error ?? this.error,
      openedName: openedName ?? this.openedName,
      openedPurchaseId: openedPurchaseId ?? this.openedPurchaseId,
      openSerial: openSerial ?? this.openSerial,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        loading,
        books,
        offlinePurchaseIds,
        downloadingPurchaseIds,
        error,
        openedName,
        openedPurchaseId,
        openSerial,
      ];
}

class PurchasesCubit extends Cubit<PurchasesState> {
  PurchasesCubit({
    required this._getPurchasedBooks,
    required this._isAvailableOffline,
    required this._downloadForOffline,
  }) : super(const PurchasesState());

  final GetPurchasedBooksUseCase _getPurchasedBooks;
  final IsPurchaseAvailableOfflineUseCase _isAvailableOffline;
  final DownloadPurchaseForOfflineUseCase _downloadForOffline;

  Future<void> load({String query = ''}) async {
    emit(state.copyWith(loading: true, clearError: true));
    final Either<Failure, List<PurchasedBook>> result =
        await _getPurchasedBooks(query);
    if (isClosed) return;
    await result.fold(
      (Failure failure) async {
        emit(state.copyWith(loading: false, error: failure.message));
      },
      (List<PurchasedBook> books) async {
        final List<PurchasedBook> digitalBooks = books
            .where(
              (PurchasedBook book) =>
                  book.digital && book.purchaseId.trim().isNotEmpty,
            )
            .toList(growable: false);
        final List<Either<Failure, bool>> availability = await Future.wait(
          digitalBooks.map(
            (PurchasedBook book) => _isAvailableOffline(book.purchaseId),
          ),
        );
        if (isClosed) return;
        final Set<String> offlineIds = <String>{};
        for (int index = 0; index < digitalBooks.length; index++) {
          availability[index].fold(
            (_) {},
            (bool available) {
              if (available) offlineIds.add(digitalBooks[index].purchaseId);
            },
          );
        }
        emit(
          state.copyWith(
            loading: false,
            books: books,
            offlinePurchaseIds: offlineIds,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<bool> download(PurchasedBook book) async {
    final String purchaseId = book.purchaseId.trim();
    if (!book.digital ||
        purchaseId.isEmpty ||
        state.downloadingPurchaseIds.contains(purchaseId)) {
      return false;
    }
    final Set<String> downloading = <String>{
      ...state.downloadingPurchaseIds,
      purchaseId,
    };
    emit(
      state.copyWith(
        downloadingPurchaseIds: downloading,
        clearError: true,
      ),
    );
    final Either<Failure, Unit> result = await _downloadForOffline(purchaseId);
    if (isClosed) return false;
    final bool success = result.isRight();
    final String? error = result.getLeft().toNullable()?.message;
    final Set<String> remaining = <String>{...state.downloadingPurchaseIds}
      ..remove(purchaseId);
    final Set<String> offline = <String>{...state.offlinePurchaseIds};
    if (success) offline.add(purchaseId);
    emit(
      state.copyWith(
        downloadingPurchaseIds: remaining,
        offlinePurchaseIds: offline,
        error: error,
        clearError: error == null,
      ),
    );
    return success;
  }

  void open(PurchasedBook book) {
    if (!state.isOffline(book)) return;
    emit(
      state.copyWith(
        openedName: book.title,
        openedPurchaseId: book.purchaseId,
        openSerial: state.openSerial + 1,
        clearError: true,
      ),
    );
  }
}
