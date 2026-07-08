import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../domain/repositories/library_details_repository.dart';
import '../../domain/use_cases/get_library_books_use_case.dart';
import 'library_details_state.dart';

class LibraryDetailsCubit extends Cubit<LibraryDetailsState> {
  LibraryDetailsCubit({
    required this.libraryId,
    required this._getLibraryBooksUseCase,
    this._pageSize = _defaultPageSize,
  }) : super(const LibraryDetailsState());

  static const int _defaultPageSize = 10;

  final String libraryId;
  final int _pageSize;
  final GetLibraryBooksUseCase _getLibraryBooksUseCase;

  Future<void> loadBooks() async {
    emit(state.copyWith(status: LibraryDetailsStatus.loading));

    final result = await _getLibraryBooksUseCase(
      GetLibraryBooksParams(
        libraryId: libraryId,
        pageNumber: 1,
        pageSize: _pageSize,
        searchTerm: '',
        sortBy: '',
        sortDescending: false,
      ),
    );

    switch (result) {
      case Success<LibraryBooksPage>(value: final LibraryBooksPage page):
        emit(
          state.copyWith(
            status: LibraryDetailsStatus.success,
            books: page.items,
            hasMore: page.hasNextPage,
            errorMessage: null,
          ),
        );
      case ResultFailure<LibraryBooksPage>(message: final String message):
        emit(
          state.copyWith(
            status: LibraryDetailsStatus.error,
            errorMessage: message,
          ),
        );
    }
  }
}
