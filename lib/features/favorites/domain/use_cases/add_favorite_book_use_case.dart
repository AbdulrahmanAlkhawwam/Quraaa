import '../../../../core/use_cases/use_case.dart';
import '../entities/favorite_book.dart';
import '../repositories/favorite_books_repository.dart';

class AddFavoriteBookUseCase extends UseCase<FavoriteBook, String> {
  const AddFavoriteBookUseCase(this._repository);

  final FavoriteBooksRepository _repository;

  @override
  FutureEither<FavoriteBook> call(String bookId) =>
      _repository.addFavorite(bookId);
}
