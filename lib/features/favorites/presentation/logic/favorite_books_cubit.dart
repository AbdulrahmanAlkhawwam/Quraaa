import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite_book.dart';
import '../../domain/use_cases/get_favorite_books_use_case.dart';
import '../../domain/use_cases/remove_favorite_book_use_case.dart';

sealed class FavoriteBooksState {
  const FavoriteBooksState();
}

final class FavoriteBooksInitial extends FavoriteBooksState {
  const FavoriteBooksInitial();
}

final class FavoriteBooksLoading extends FavoriteBooksState {
  const FavoriteBooksLoading();
}

final class FavoriteBooksLoaded extends FavoriteBooksState {
  const FavoriteBooksLoaded(this.items);
  final List<FavoriteBook> items;
}

final class FavoriteBooksFailure extends FavoriteBooksState {
  const FavoriteBooksFailure(this.message);
  final String message;
}

class FavoriteBooksCubit extends Cubit<FavoriteBooksState> {
  FavoriteBooksCubit({required this.getFavorites, required this.removeFavorite})
    : super(const FavoriteBooksInitial());

  final GetFavoriteBooksUseCase getFavorites;
  final RemoveFavoriteBookUseCase removeFavorite;

  Future<void> load() async {
    emit(const FavoriteBooksLoading());
    final result = await getFavorites(const GetFavoriteBooksParams());
    emit(
      result.fold(
        (Failure failure) => FavoriteBooksFailure(failure.message),
        (FavoriteBooksPage page) => FavoriteBooksLoaded(page.items),
      ),
    );
  }

  Future<void> remove(String bookId) async {
    final FavoriteBooksState current = state;
    if (current is! FavoriteBooksLoaded) return;
    final result = await removeFavorite(bookId);
    emit(
      result.fold(
        (Failure failure) => FavoriteBooksFailure(failure.message),
        (_) => FavoriteBooksLoaded(
          current.items.where((item) => item.bookId != bookId).toList(),
        ),
      ),
    );
  }
}
