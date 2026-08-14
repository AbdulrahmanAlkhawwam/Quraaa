import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../domain/entities/favorite_book.dart';
import '../../domain/use_cases/add_favorite_book_use_case.dart';
import '../../domain/use_cases/is_favorite_book_use_case.dart';
import '../../domain/use_cases/remove_favorite_book_use_case.dart';

class FavoriteStatusState {
  const FavoriteStatusState({
    this.isFavorite = false,
    this.isLoading = false,
    this.error,
  });

  final bool isFavorite;
  final bool isLoading;
  final String? error;
}

class FavoriteStatusCubit extends Cubit<FavoriteStatusState> {
  FavoriteStatusCubit({
    required this.isFavoriteBook,
    required this.addFavorite,
    required this.removeFavorite,
  }) : super(const FavoriteStatusState());

  final IsFavoriteBookUseCase isFavoriteBook;
  final AddFavoriteBookUseCase addFavorite;
  final RemoveFavoriteBookUseCase removeFavorite;

  Future<void> load(String bookId) async {
    emit(FavoriteStatusState(isLoading: true, isFavorite: state.isFavorite));
    final Result<bool> result = await isFavoriteBook(bookId);
    switch (result) {
      case Success<bool>(value: final value):
        emit(FavoriteStatusState(isFavorite: value));
      case ResultFailure<bool>(message: final message):
        emit(FavoriteStatusState(error: message));
    }
  }

  Future<void> toggle(String bookId) async {
    if (state.isLoading || bookId.trim().isEmpty) return;
    final bool wasFavorite = state.isFavorite;
    emit(FavoriteStatusState(isFavorite: wasFavorite, isLoading: true));
    if (wasFavorite) {
      final Result<bool> result = await removeFavorite(bookId);
      switch (result) {
        case Success<bool>():
          emit(const FavoriteStatusState(isFavorite: false));
        case ResultFailure<bool>(message: final message):
          emit(FavoriteStatusState(isFavorite: true, error: message));
      }
      return;
    }

    final Result<FavoriteBook> result = await addFavorite(bookId);
    switch (result) {
      case Success<FavoriteBook>():
        emit(const FavoriteStatusState(isFavorite: true));
      case ResultFailure<FavoriteBook>(message: final message):
        emit(FavoriteStatusState(error: message));
    }
  }
}
