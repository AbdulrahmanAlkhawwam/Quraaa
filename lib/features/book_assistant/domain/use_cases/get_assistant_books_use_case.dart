import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/assistant_book.dart';
import '../repositories/book_assistant_repository.dart';

class GetAssistantBooksUseCase
    extends UseCase<Result<List<AssistantBook>>, NoParams> {
  const GetAssistantBooksUseCase(this._repository);

  final BookAssistantRepository _repository;

  @override
  Future<Result<List<AssistantBook>>> call(NoParams params) {
    return _repository.getSuggestedBooks();
  }
}

