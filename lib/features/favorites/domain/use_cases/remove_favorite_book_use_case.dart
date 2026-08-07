import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/favorite_books_repository.dart';

class RemoveFavoriteBookUseCase extends UseCase<Result<bool>, String> {
  const RemoveFavoriteBookUseCase(this._repository);

  final FavoriteBooksRepository _repository;

  @override
  Future<Result<bool>> call(String bookId) =>
      _repository.removeFavorite(bookId);
}
