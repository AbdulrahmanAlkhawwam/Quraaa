import '../../../../core/architecture/result.dart';
import '../entities/favorite_book.dart';

abstract class FavoriteBooksRepository {
  const FavoriteBooksRepository();

  Future<Result<FavoriteBooksPage>> getFavoriteBooks({
    required int pageNumber,
    required int pageSize,
    String searchTerm = '',
  });

  Future<Result<FavoriteBook>> addFavorite(String bookId);

  Future<Result<bool>> removeFavorite(String bookId);

  Future<Result<bool>> isFavorite(String bookId);
}
