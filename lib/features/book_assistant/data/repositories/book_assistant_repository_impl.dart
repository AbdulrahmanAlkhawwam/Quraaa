import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/assistant_book.dart';
import '../../domain/entities/assistant_response.dart';
import '../../domain/repositories/book_assistant_repository.dart';
import '../data_sources/book_assistant_remote_data_source.dart';
import '../models/book_summary_model.dart';

class BookAssistantRepositoryImpl extends BookAssistantRepository {
  const BookAssistantRepositoryImpl(this._remoteDataSource);

  final BookAssistantRemoteDataSource _remoteDataSource;

  static const String _defaultQuestionAr =
      '\u062F\u0644\u0646\u064A \u0639\u0644\u0649 \u0645\u0627 \u0623\u0631\u064A\u062F';
  static const String _defaultQuestionEn = 'Guide me to a book';
  static const String _generalLibraryHintAr =
      '\u0627\u0639\u062A\u0645\u0627\u062F\u0627 \u0639\u0644\u0649 \u0645\u0643\u062A\u0628\u062A\u0643 \u0627\u0644\u0639\u0627\u0645\u0629';
  static const String _generalLibraryHintEn = 'Based on your general library';
  static const String _selectedBooksPrefixAr =
      '\u0627\u0639\u062A\u0645\u0627\u062F\u0627 \u0639\u0644\u0649';
  static const String _selectedBooksSuffixAr =
      '\u0643\u062A\u0628 \u0627\u062E\u062A\u0631\u062A\u0647\u0627';
  static const String _answerBodyAr =
      '\u060C \u0647\u0630\u0647 \u0625\u062C\u0627\u0628\u0629 \u062A\u062C\u0631\u064A\u0628\u064A\u0629 \u062A\u0633\u0627\u0639\u062F\u0643 \u0639\u0644\u0649 \u0627\u0644\u0642\u0631\u0627\u0621\u0629 \u0628\u0630\u0643\u0627\u0621: \u0627\u0628\u062F\u0623 \u0628\u0627\u0644\u0641\u0643\u0631\u0629 \u0627\u0644\u0631\u0626\u064A\u0633\u064A\u0629\u060C \u062B\u0645 \u0627\u0642\u0631\u0623 \u0627\u0644\u0639\u0646\u0627\u0648\u064A\u0646 \u0627\u0644\u0641\u0631\u0639\u064A\u0629\u060C \u0648\u0628\u0639\u062F\u0647\u0627 \u0627\u0633\u0623\u0644\u0646\u064A \u0639\u0646 \u0623\u064A \u0641\u0642\u0631\u0629 \u062A\u0631\u064A\u062F \u062A\u0644\u062E\u064A\u0635\u0647\u0627 \u0623\u0648 \u0634\u0631\u062D\u0647\u0627 \u0628\u0644\u063A\u0629 \u0623\u0628\u0633\u0637.';
  static const String _answerBodyEn =
      ', this is a sample answer to help you read smarter: start with the main idea, scan the section headings, then ask me about any paragraph you want summarized or explained in simpler language.';

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
  FutureEither<List<AssistantBook>> getSuggestedBooks() async {
    return const Right<Failure, List<AssistantBook>>(_books);
  }

  @override
  FutureEither<String> summarize({required String purchaseId}) async {
    try {
      final BookSummaryModel model = await _remoteDataSource.summarize(
        purchaseId: purchaseId,
      );
      return Right(model.summary);
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  FutureEither<String> translate({
    required String purchaseId,
    required int pageNumber,
    required String targetLanguage,
  }) async {
    try {
      return Right(await _remoteDataSource.translate(
        purchaseId: purchaseId,
        pageNumber: pageNumber,
        targetLanguage: targetLanguage,
      ));
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  FutureEither<String> explain({
    required String purchaseId,
    required String selectedText,
  }) async {
    try {
      return Right(await _remoteDataSource.explain(
        purchaseId: purchaseId,
        selectedText: selectedText,
      ));
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }

  @override
  FutureEither<AssistantResponse> ask({
    required String question,
    required List<AssistantBook> books,
  }) async {
    // Temporary mock endpoint: keep the same latency users will experience
    // while the backend endpoint is being completed.
    await Future<void>.delayed(const Duration(seconds: 2));
    final String trimmedQuestion = question.trim();
    final bool useArabic = _containsArabic(trimmedQuestion);
    final String normalizedQuestion = trimmedQuestion.isEmpty
        ? (useArabic ? _defaultQuestionAr : _defaultQuestionEn)
        : trimmedQuestion;
    final String bookHint = books.isEmpty
        ? (useArabic ? _generalLibraryHintAr : _generalLibraryHintEn)
        : useArabic
            ? '$_selectedBooksPrefixAr ${books.length} $_selectedBooksSuffixAr'
            : 'Based on ${books.length} selected books';
    final String answerBody = useArabic ? _answerBodyAr : _answerBodyEn;

    return Right(
      AssistantResponse(
        question: normalizedQuestion,
        books: books,
        answer: '$bookHint$answerBody',
      ),
    );
  }

  bool _containsArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}
