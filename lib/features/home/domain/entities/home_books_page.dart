import 'package:equatable/equatable.dart';

import 'home_book_entity.dart';

/// One page of home-screen books. The paging fields arrive as strings from the
/// backend and are kept verbatim.
class HomeBooksPage extends Equatable {
  const HomeBooksPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<HomeBookEntity> items;
  final String pageNumber;
  final String pageSize;
  final String totalCount;
  final String totalPages;
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
