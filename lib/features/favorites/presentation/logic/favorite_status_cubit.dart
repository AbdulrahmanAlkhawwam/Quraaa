import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
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
    final result = await isFavoriteBook(bookId);
    emit(
      result.fold(
        (Failure failure) => FavoriteStatusState(error: failure.message),
        (bool value) => FavoriteStatusState(isFavorite: value),
      ),
    );
  }

  Future<void> toggle(String bookId) async {
    if (state.isLoading || bookId.trim().isEmpty) return;
    final bool wasFavorite = state.isFavorite;
    emit(FavoriteStatusState(isFavorite: wasFavorite, isLoading: true));
    if (wasFavorite) {
      final result = await removeFavorite(bookId);
      emit(
        result.fold(
          (Failure failure) =>
              FavoriteStatusState(isFavorite: true, error: failure.message),
          (_) => const FavoriteStatusState(isFavorite: false),
        ),
      );
      return;
    }

    final result = await addFavorite(bookId);
    emit(
      result.fold(
        (Failure failure) => FavoriteStatusState(error: failure.message),
        (_) => const FavoriteStatusState(isFavorite: true),
      ),
    );
  }
}
