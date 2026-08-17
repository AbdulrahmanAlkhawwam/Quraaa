import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/architecture/result.dart';
import '../domain/purchases.dart';

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
  PurchasesCubit(this._repository) : super(const PurchasesState());

  final PurchasesRepository _repository;

  Future<void> load({String query = ''}) async {
    emit(state.copyWith(loading: true, clearError: true));
    final Result<List<PurchasedBook>> result =
        await _repository.getLibrary(query: query);
    if (isClosed) return;
    await result.fold(
      (failure) async {
        emit(state.copyWith(loading: false, error: failure.message));
      },
      (List<PurchasedBook> books) async {
        final List<PurchasedBook> digitalBooks = books
            .where(
              (PurchasedBook book) =>
                  book.digital && book.purchaseId.trim().isNotEmpty,
            )
            .toList(growable: false);
        final List<Result<bool>> availability = await Future.wait(
          digitalBooks.map(
            (PurchasedBook book) =>
                _repository.isAvailableOffline(book.purchaseId),
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
    final Result<void> result =
        await _repository.downloadForOffline(purchaseId);
    if (isClosed) return false;
    bool success = false;
    String? error;
    result.fold(
      (failure) => error = failure.message,
      (_) => success = true,
    );
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
