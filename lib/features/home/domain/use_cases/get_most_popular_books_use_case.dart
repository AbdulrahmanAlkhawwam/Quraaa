import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/home_books_repository.dart';

class GetMostPopularBooksUseCase
    extends UseCase<Result<HomeBooksPage>, NoParams> {
  const GetMostPopularBooksUseCase(this._repository);

  final HomeBooksRepository _repository;

  @override
  Future<Result<HomeBooksPage>> call(NoParams params) {
    return _repository.getMostPopularBooks();
  }
}
