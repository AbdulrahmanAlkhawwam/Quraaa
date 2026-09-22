import '../../../../core/use_cases/use_case.dart';
import '../repositories/favorite_books_repository.dart';

class RemoveFavoriteBookUseCase extends UseCase<bool, String> {
  const RemoveFavoriteBookUseCase(this._repository);

  final FavoriteBooksRepository _repository;

  @override
  FutureEither<bool> call(String bookId) => _repository.removeFavorite(bookId);
}
