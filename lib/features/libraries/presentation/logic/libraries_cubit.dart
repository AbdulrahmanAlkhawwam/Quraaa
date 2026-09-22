import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:meta/meta.dart';

import '../../../../core/architecture/result.dart';
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
  int _requestGeneration = 0;

  Future<void> loadUserSnapshot() async {
    // The header profile is optional; on failure library paging stays usable.
    final AccountUserSnapshot? userSnapshot = (await _loadUserSnapshotUseCase())
        .toNullable();
    if (userSnapshot == null || isClosed) return;
    emit(state.copyWith(userSnapshot: userSnapshot));
  }

  void updateSearchTerm(String searchTerm) {
    if (isClosed || searchTerm == state.searchTerm) return;

    _requestGeneration++;
    emit(state.copyWith(searchTerm: searchTerm));
    state.pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    if (isClosed) return;

    final int requestGeneration = _requestGeneration;
    final String searchTerm = state.searchTerm;
    final int pageSize = state.pageSize;
    emit(state.copyWith(status: LibrariesStatus.loading));

    final Result<LibrariesPage> result = await _getLibrariesUseCase(
      GetLibrariesParams(
        searchTerm: searchTerm,
        pageNumber: pageKey,
        pageSize: pageSize,
      ),
    );

    if (isClosed || requestGeneration != _requestGeneration) return;

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
    _requestGeneration++;
    state.pagingController
      ..removePageRequestListener(_fetchPage)
      ..dispose();
    return super.close();
  }
}
