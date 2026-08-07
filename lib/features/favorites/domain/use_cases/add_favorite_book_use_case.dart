import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/favorite_book.dart';
import '../repositories/favorite_books_repository.dart';

class AddFavoriteBookUseCase extends UseCase<Result<FavoriteBook>, String> {
  const AddFavoriteBookUseCase(this._repository);

  final FavoriteBooksRepository _repository;

  @override
  Future<Result<FavoriteBook>> call(String bookId) =>
      _repository.addFavorite(bookId);
}
