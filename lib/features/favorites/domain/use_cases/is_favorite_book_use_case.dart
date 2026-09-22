import '../../../../core/use_cases/use_case.dart';
import '../repositories/favorite_books_repository.dart';

class IsFavoriteBookUseCase extends UseCase<bool, String> {
  const IsFavoriteBookUseCase(this._repository);

  final FavoriteBooksRepository _repository;

  @override
  FutureEither<bool> call(String bookId) => _repository.isFavorite(bookId);
}
