import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/home_books_repository.dart';

class GetRecommendedBooksUseCase
    extends UseCase<Result<HomeBooksPage>, NoParams> {
  const GetRecommendedBooksUseCase(this._repository);

  final HomeBooksRepository _repository;

  @override
  Future<Result<HomeBooksPage>> call(NoParams params) {
    return _repository.getRecommendedBooks();
  }
}
