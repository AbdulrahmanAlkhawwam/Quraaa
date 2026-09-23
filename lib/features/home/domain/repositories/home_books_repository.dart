import '../../../../core/use_cases/use_case.dart';
import '../entities/home_books_page.dart';

abstract class HomeBooksRepository {
  FutureEither<HomeBooksPage> getRecommendedBooks();

  FutureEither<HomeBooksPage> getMostPopularBooks();
}
