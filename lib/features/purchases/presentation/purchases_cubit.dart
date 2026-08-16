import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/architecture/result.dart';
import '../domain/purchases.dart';

class PurchasesState extends Equatable {
  const PurchasesState({
    this.loading = false,
    this.openingId,
    this.books = const <PurchasedBook>[],
    this.error,
    this.openedPath,
    this.openedName,
    this.openedPurchaseId,
    this.openSerial = 0,
  });

  final bool loading;
  final String? openingId;
  final List<PurchasedBook> books;
  final String? error;
  final String? openedPath;
  final String? openedName;
  final String? openedPurchaseId;
  final int openSerial;

  @override
  List<Object?> get props => <Object?>[
        loading,
        openingId,
        books,
        error,
        openedPath,
        openedName,
        openedPurchaseId,
        openSerial,
      ];
}

class PurchasesCubit extends Cubit<PurchasesState> {
  PurchasesCubit(this._repository) : super(const PurchasesState());

  final PurchasesRepository _repository;

  Future<void> load({String query = ''}) async {
    emit(PurchasesState(loading: true, books: state.books));
    final Result<List<PurchasedBook>> result =
        await _repository.getLibrary(query: query);
    if (isClosed) return;
    result.fold(
      (failure) =>
          emit(PurchasesState(books: state.books, error: failure.message)),
      (books) => emit(PurchasesState(books: books)),
    );
  }

  void open(PurchasedBook book) {
    emit(
      PurchasesState(
        books: state.books,
        openedName: book.title,
        openedPurchaseId: book.purchaseId,
        openSerial: state.openSerial + 1,
      ),
    );
  }
}
