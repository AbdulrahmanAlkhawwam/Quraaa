import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/authors_repository.dart';

class AuthorDetailsState extends Equatable {
  const AuthorDetailsState({
    this.loading = false,
    this.author,
    this.books = const <AuthorBookEntity>[],
    this.error,
  });

  final bool loading;
  final AuthorEntity? author;
  final List<AuthorBookEntity> books;
  final String? error;

  @override
  List<Object?> get props => <Object?>[loading, author, books, error];
}

class AuthorDetailsCubit extends Cubit<AuthorDetailsState> {
  AuthorDetailsCubit(this._repository, this.authorId)
      : super(const AuthorDetailsState());

  final AuthorsRepository _repository;
  final String authorId;

  Future<void> load() async {
    if (authorId.trim().isEmpty) return;
    emit(AuthorDetailsState(
      loading: true,
      author: state.author,
      books: state.books,
    ));
    final List<Result<dynamic>> results =
        await Future.wait(<Future<Result<dynamic>>>[
      _repository.getAuthor(authorId),
      _repository.getAuthorBooks(authorId),
    ]);
    if (isClosed) return;
    AuthorEntity? author = state.author;
    List<AuthorBookEntity> books = state.books;
    String? error;
    results[0].fold(
      (failure) => error = failure.message,
      (value) => author = value as AuthorEntity,
    );
    results[1].fold(
      (failure) => error ??= failure.message,
      (value) => books = (value as AuthorBooksPage).items,
    );
    emit(AuthorDetailsState(author: author, books: books, error: error));
  }
}
