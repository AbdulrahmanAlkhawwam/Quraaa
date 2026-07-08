import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/library_details_repository.dart';

class GetLibraryBooksParams {
  const GetLibraryBooksParams({
    required this.libraryId,
    required this.pageNumber,
    required this.pageSize,
    this.searchTerm,
    this.sortBy,
    this.sortDescending,
  });

  final String libraryId;
  final int pageNumber;
  final int pageSize;
  final String? searchTerm;
  final String? sortBy;
  final bool? sortDescending;
}

class GetLibraryBooksUseCase
    extends UseCase<Result<LibraryBooksPage>, GetLibraryBooksParams> {
  const GetLibraryBooksUseCase(this._repository);

  final LibraryDetailsRepository _repository;

  @override
  Future<Result<LibraryBooksPage>> call(GetLibraryBooksParams params) {
    return _repository.getLibraryBooks(
      libraryId: params.libraryId,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      searchTerm: params.searchTerm,
      sortBy: params.sortBy,
      sortDescending: params.sortDescending,
    );
  }
}
