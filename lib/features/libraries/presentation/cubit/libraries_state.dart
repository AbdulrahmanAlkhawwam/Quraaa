part of 'libraries_cubit.dart';

@immutable
class LibrariesState extends Equatable {
  const LibrariesState({
    required this.searchTerm,
    required this.pageSize,
    required this.pagingController,
    this.status = LibrariesStatus.initial,
    this.errorMessage,
  });

  final String searchTerm;
  final int pageSize;
  final LibrariesStatus status;
  final String? errorMessage;
  final PagingController<int, LibraryEntity> pagingController;

  LibrariesState copyWith({
    String? searchTerm,
    int? pageSize,
    LibrariesStatus? status,
    String? errorMessage,
  }) {
    return LibrariesState(
      searchTerm: searchTerm ?? this.searchTerm,
      pageSize: pageSize ?? this.pageSize,
      pagingController: pagingController,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        searchTerm,
        pageSize,
        status,
        errorMessage,
        pagingController,
      ];
}

enum LibrariesStatus { initial, loading, success, error }
