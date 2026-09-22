import '../../../../core/use_cases/use_case.dart';
import '../entities/favorite_book.dart';

abstract class FavoriteBooksRepository {
  const FavoriteBooksRepository();

  FutureEither<FavoriteBooksPage> getFavoriteBooks({
    required int pageNumber,
    required int pageSize,
    String searchTerm = '',
  });

  FutureEither<FavoriteBook> addFavorite(String bookId);

  FutureEither<bool> removeFavorite(String bookId);

  FutureEither<bool> isFavorite(String bookId);
}
