import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../entities/author_entity.dart';

abstract class AuthorsRepository {
  const AuthorsRepository();

  Future<Result<AuthorEntity>> getAuthor(String authorId);

  Future<Result<AuthorBooksPage>> getAuthorBooks(
    String authorId, {
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<Result<AuthorSearchPage>> searchAuthors(
    String searchTerm, {
    int pageNumber = 1,
    int pageSize = 10,
  });
}

class AuthorBooksPage extends Equatable {
  const AuthorBooksPage({required this.items, required this.hasNextPage});

  final List<AuthorBookEntity> items;
  final bool hasNextPage;

  @override
  List<Object?> get props => <Object?>[items, hasNextPage];
}

class AuthorSearchPage extends Equatable {
  const AuthorSearchPage({
    required this.items,
    required this.totalCount,
    required this.hasNextPage,
  });

  final List<AuthorSearchResult> items;
  final int totalCount;
  final bool hasNextPage;

  @override
  List<Object?> get props => <Object?>[items, totalCount, hasNextPage];
}
