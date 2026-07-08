import 'package:equatable/equatable.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/assistant_book.dart';
import '../entities/assistant_response.dart';
import '../repositories/book_assistant_repository.dart';

class AskBookAssistantUseCase
    extends UseCase<Result<AssistantResponse>, AskBookAssistantParams> {
  const AskBookAssistantUseCase(this._repository);

  final BookAssistantRepository _repository;

  @override
  Future<Result<AssistantResponse>> call(AskBookAssistantParams params) {
    return _repository.ask(
      question: params.question,
      books: params.books,
    );
  }
}

class AskBookAssistantParams extends Equatable {
  const AskBookAssistantParams({
    required this.question,
    required this.books,
  });

  final String question;
  final List<AssistantBook> books;

  @override
  List<Object?> get props => <Object?>[question, books];
}

