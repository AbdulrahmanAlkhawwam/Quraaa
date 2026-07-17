part of 'libraries_cubit.dart';

@immutable
class LibrariesState extends Equatable {
  const LibrariesState({
    required this.searchTerm,
    required this.pageSize,
    required this.pagingController,
    this.status = LibrariesStatus.initial,
    this.userSnapshot,
    this.errorMessage,
  });

  final String searchTerm;
  final int pageSize;
  final LibrariesStatus status;
  final AccountUserSnapshot? userSnapshot;
  final String? errorMessage;
  final PagingController<int, LibraryEntity> pagingController;

  String get firstName => userSnapshot?.firstName ?? '';
  String? get profileImage => userSnapshot?.profileImage;

  LibrariesState copyWith({
    String? searchTerm,
    int? pageSize,
    LibrariesStatus? status,
    AccountUserSnapshot? userSnapshot,
    String? errorMessage,
  }) {
    return LibrariesState(
      searchTerm: searchTerm ?? this.searchTerm,
      pageSize: pageSize ?? this.pageSize,
      pagingController: pagingController,
      status: status ?? this.status,
      userSnapshot: userSnapshot ?? this.userSnapshot,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        searchTerm,
        pageSize,
        status,
        userSnapshot,
        errorMessage,
        pagingController,
      ];
}

enum LibrariesStatus { initial, loading, success, error }