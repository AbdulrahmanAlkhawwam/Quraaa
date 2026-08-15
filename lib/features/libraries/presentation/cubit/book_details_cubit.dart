import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../domain/entities/library_book_entity.dart';
import '../../domain/use_cases/get_listing_details_use_case.dart';
import 'book_details_state.dart';

class BookDetailsCubit extends Cubit<BookDetailsState> {
  BookDetailsCubit(this._getListingDetailsUseCase)
      : super(const BookDetailsState());

  final GetListingDetailsUseCase _getListingDetailsUseCase;
  String _detailsId = '';

  Future<void> load({
    required String detailsId,
    LibraryBookEntity? fallbackBook,
  }) async {
    _detailsId = detailsId.trim();
    emit(
      state.copyWith(
        status: BookDetailsStatus.loading,
        book: fallbackBook,
        clearError: true,
      ),
    );

    if (_detailsId.isEmpty) {
      emit(
        state.copyWith(
          status: BookDetailsStatus.error,
          errorMessage: 'Missing listing id.',
        ),
      );
      return;
    }

    final Result<LibraryBookEntity> result = await _getListingDetailsUseCase(
      GetListingDetailsParams(_detailsId),
    );

    switch (result) {
      case Success<LibraryBookEntity>(value: final LibraryBookEntity book):
        emit(
          state.copyWith(
            status: BookDetailsStatus.success,
            book: book,
            clearError: true,
          ),
        );
      case ResultFailure<LibraryBookEntity>(message: final String message):
        emit(
          state.copyWith(
            status: BookDetailsStatus.error,
            errorMessage: message,
          ),
        );
    }
  }

  Future<void> retry() => load(detailsId: _detailsId, fallbackBook: state.book);
}
