import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:meta/meta.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../account/account.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/repositories/libraries_repository.dart';
import '../../domain/use_cases/get_libraries_use_case.dart';

part 'libraries_state.dart';

class LibrariesCubit extends Cubit<LibrariesState> {
  LibrariesCubit({
    required GetLibrariesUseCase getLibrariesUseCase,
    required LoadAccountUserSnapshotUseCase loadUserSnapshotUseCase,
    String initialSearchTerm = '',
    int pageSize = _defaultPageSize,
  })  : _getLibrariesUseCase = getLibrariesUseCase,
        _loadUserSnapshotUseCase = loadUserSnapshotUseCase,
        super(
          LibrariesState(
            searchTerm: initialSearchTerm,
            pageSize: pageSize,
            pagingController: PagingController<int, LibraryEntity>(
              firstPageKey: 1,
            ),
          ),
        ) {
    state.pagingController.addPageRequestListener(_fetchPage);
  }

  static const int _defaultPageSize = 10;

  final GetLibrariesUseCase _getLibrariesUseCase;
  final LoadAccountUserSnapshotUseCase _loadUserSnapshotUseCase;

  Future<void> loadUserSnapshot() async {
    try {
      final AccountUserSnapshot userSnapshot = await _loadUserSnapshotUseCase(
        const NoParams(),
      );
      emit(state.copyWith(userSnapshot: userSnapshot));
    } catch (_) {
      // The header profile is optional; library paging should remain usable.
    }
  }

  void updateSearchTerm(String searchTerm) {
    if (searchTerm == state.searchTerm) return;

    emit(state.copyWith(searchTerm: searchTerm));
    state.pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    emit(state.copyWith(status: LibrariesStatus.loading));

    final result = await _getLibrariesUseCase(
      GetLibrariesParams(
        searchTerm: state.searchTerm,
        pageNumber: pageKey,
        pageSize: state.pageSize,
      ),
    );

    switch (result) {
      case Success<LibrariesPage>(value: final LibrariesPage page):
        final bool isLastPage = !page.hasNextPage;

        if (isLastPage) {
          state.pagingController.appendLastPage(page.items);
        } else {
          state.pagingController.appendPage(page.items, pageKey + 1);
        }

        emit(
          state.copyWith(
            status: page.items.isEmpty && pageKey == 1
                ? LibrariesStatus.initial
                : LibrariesStatus.success,
            errorMessage: null,
          ),
        );
      case ResultFailure<LibrariesPage>(message: final String message):
        state.pagingController.error = message;
        emit(
          state.copyWith(
            status: LibrariesStatus.error,
            errorMessage: message,
          ),
        );
    }
  }

  @override
  Future<void> close() {
    state.pagingController.dispose();
    return super.close();
  }
}