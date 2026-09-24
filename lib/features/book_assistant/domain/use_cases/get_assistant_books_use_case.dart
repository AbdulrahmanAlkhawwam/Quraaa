import '../../../../core/use_cases/use_case.dart';
import '../entities/assistant_book.dart';
import '../repositories/book_assistant_repository.dart';

class GetAssistantBooksUseCase
    extends NoParamsUseCase<List<AssistantBook>> {
  const GetAssistantBooksUseCase(this._repository);

  final BookAssistantRepository _repository;

  @override
  FutureEither<List<AssistantBook>> call() {
    return _repository.getSuggestedBooks();
  }
}

