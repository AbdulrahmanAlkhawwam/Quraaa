import '../../../../core/architecture/result.dart';
import '../../domain/entities/assistant_book.dart';
import '../../domain/entities/assistant_response.dart';
import '../../domain/repositories/book_assistant_repository.dart';

class BookAssistantRepositoryImpl extends BookAssistantRepository {
  const BookAssistantRepositoryImpl();

  static const String _defaultQuestion =
      '\u062F\u0644\u0646\u064A \u0639\u0644\u0649 \u0645\u0627 \u0623\u0631\u064A\u062F';
  static const String _generalLibraryHint =
      '\u0627\u0639\u062A\u0645\u0627\u062F\u0627 \u0639\u0644\u0649 \u0645\u0643\u062A\u0628\u062A\u0643 \u0627\u0644\u0639\u0627\u0645\u0629';
  static const String _selectedBooksPrefix =
      '\u0627\u0639\u062A\u0645\u0627\u062F\u0627 \u0639\u0644\u0649';
  static const String _selectedBooksSuffix =
      '\u0643\u062A\u0628 \u0627\u062E\u062A\u0631\u062A\u0647\u0627';
  static const String _answerBody =
      '\u060C \u0647\u0630\u0647 \u0625\u062C\u0627\u0628\u0629 \u062A\u062C\u0631\u064A\u0628\u064A\u0629 \u062A\u0633\u0627\u0639\u062F\u0643 \u0639\u0644\u0649 \u0627\u0644\u0642\u0631\u0627\u0621\u0629 \u0628\u0630\u0643\u0627\u0621: \u0627\u0628\u062F\u0623 \u0628\u0627\u0644\u0641\u0643\u0631\u0629 \u0627\u0644\u0631\u0626\u064A\u0633\u064A\u0629\u060C \u062B\u0645 \u0627\u0642\u0631\u0623 \u0627\u0644\u0639\u0646\u0627\u0648\u064A\u0646 \u0627\u0644\u0641\u0631\u0639\u064A\u0629\u060C \u0648\u0628\u0639\u062F\u0647\u0627 \u0627\u0633\u0623\u0644\u0646\u064A \u0639\u0646 \u0623\u064A \u0641\u0642\u0631\u0629 \u062A\u0631\u064A\u062F \u062A\u0644\u062E\u064A\u0635\u0647\u0627 \u0623\u0648 \u0634\u0631\u062D\u0647\u0627 \u0628\u0644\u063A\u0629 \u0623\u0628\u0633\u0637.';

  static const List<AssistantBook> _books = <AssistantBook>[
    AssistantBook(
      id: 'book-1',
      title: 'Emar English book',
      author: 'Syrian Republic Arabic Gov',
      coverUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=220&q=80',
    ),
    AssistantBook(
      id: 'book-2',
      title: 'The Reading Path',
      author: 'Quraaa Library',
      coverUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=220&q=80',
    ),
    AssistantBook(
      id: 'book-3',
      title: 'Arabic Grammar Notes',
      author: 'Learning Desk',
      coverUrl:
          'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=220&q=80',
    ),
  ];

  @override
  Future<Result<List<AssistantBook>>> getSuggestedBooks() async {
    return const Success<List<AssistantBook>>(_books);
  }

  @override
  Future<Result<AssistantResponse>> ask({
    required String question,
    required List<AssistantBook> books,
  }) async {
    final String normalizedQuestion =
        question.trim().isEmpty ? _defaultQuestion : question.trim();
    final String bookHint = books.isEmpty
        ? _generalLibraryHint
        : '$_selectedBooksPrefix ${books.length} $_selectedBooksSuffix';

    return Success<AssistantResponse>(
      AssistantResponse(
        question: normalizedQuestion,
        books: books,
        answer: '$bookHint$_answerBody',
      ),
    );
  }
}
