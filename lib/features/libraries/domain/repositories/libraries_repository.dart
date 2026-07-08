import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../entities/library_entity.dart';

/// Repository contract for paginated library listings.
abstract class LibrariesRepository {
  /// Returns a page of libraries matching [searchTerm].
  Future<Result<LibrariesPage>> getLibraries({
    required String searchTerm,
    required int pageNumber,
    required int pageSize,
  });
}

/// A single page of libraries returned by the backend.
class LibrariesPage extends Equatable {
  const LibrariesPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<LibraryEntity> items;
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
