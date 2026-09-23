import '../../../../core/use_cases/use_case.dart';
import '../entities/home_books_page.dart';
import '../repositories/home_books_repository.dart';

class GetRecommendedBooksUseCase extends NoParamsUseCase<HomeBooksPage> {
  const GetRecommendedBooksUseCase(this._repository);

  final HomeBooksRepository _repository;

  @override
  FutureEither<HomeBooksPage> call() => _repository.getRecommendedBooks();
}
