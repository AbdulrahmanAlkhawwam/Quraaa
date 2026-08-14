import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/favorite_books_repository.dart';

class IsFavoriteBookUseCase extends UseCase<Result<bool>, String> {
  const IsFavoriteBookUseCase(this._repository);

  final FavoriteBooksRepository _repository;

  @override
  Future<Result<bool>> call(String bookId) => _repository.isFavorite(bookId);
}
