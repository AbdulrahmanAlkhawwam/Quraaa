import 'package:equatable/equatable.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/assistant_book.dart';
import '../entities/assistant_response.dart';
import '../repositories/book_assistant_repository.dart';

class AskBookAssistantUseCase
    extends UseCase<AssistantResponse, AskBookAssistantParams> {
  const AskBookAssistantUseCase(this._repository);

  final BookAssistantRepository _repository;

  @override
  FutureEither<AssistantResponse> call(AskBookAssistantParams params) {
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

