import 'package:equatable/equatable.dart';

import 'assistant_book.dart';

class AssistantResponse extends Equatable {
  const AssistantResponse({
    required this.question,
    required this.answer,
    required this.books,
  });

  final String question;
  final String answer;
  final List<AssistantBook> books;

  @override
  List<Object?> get props => <Object?>[question, answer, books];
}

