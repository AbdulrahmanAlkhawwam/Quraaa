import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../entities/library_book_entity.dart';

/// Repository contract for library books and individual listing details.
abstract class LibraryDetailsRepository {
  Future<Result<LibraryBooksPage>> getLibraryBooks({
    required String libraryId,
    required int pageNumber,
    required int pageSize,
    String? searchTerm,
    String? sortBy,
    bool? sortDescending,
  });

  Future<Result<LibraryBookEntity>> getListingDetails(String listingId);
}

class LibraryBooksPage extends Equatable {
  const LibraryBooksPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<LibraryBookEntity> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  @override
  List<Object?> get props => <Object?>[
        items,
        pageNumber,
        pageSize,
        totalCount,
        totalPages,
        hasNextPage,
        hasPreviousPage,
      ];
}
