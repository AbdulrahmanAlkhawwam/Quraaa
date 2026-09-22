import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/book_assistant/book_assistant.dart';

void main() {
  const AssistantBook book = AssistantBook(
    id: 'book-1',
    title: 'Global English Coursebook 10',
    author: 'Quraaa',
    coverUrl: '',
  );

  test('submitting a question shows loading then the mock response', () async {
    final BookAssistantBloc bloc = BookAssistantBloc(
      getBooks: GetAssistantBooksUseCase(const _FakeRepository()),
      askAssistant: AskBookAssistantUseCase(const _FakeRepository()),
      summarizePurchase: SummarizePurchaseUseCase(const _FakeRepository()),
    );
    addTearDown(bloc.close);

    bloc.add(const BookAssistantStarted());
    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<BookAssistantLoading>(),
        isA<BookAssistantLoaded>(),
      ]),
    );

    bloc.add(const BookAssistantQuestionSubmitted('Find an English book'));
    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<BookAssistantLoaded>()
            .having((BookAssistantLoaded state) => state.isAnswering,
                'answering', isTrue)
            .having((BookAssistantLoaded state) => state.pendingQuestion,
                'question', 'Find an English book'),
        isA<BookAssistantLoaded>()
            .having((BookAssistantLoaded state) => state.isAnswering,
                'answering', isFalse)
            .having((BookAssistantLoaded state) => state.response?.answer,
                'answer', 'Mock answer'),
      ]),
    );
  });

  test('starts a summary conversation from navigation data', () async {
    final BookAssistantBloc bloc = BookAssistantBloc(
      getBooks: GetAssistantBooksUseCase(const _FakeRepository()),
      askAssistant: AskBookAssistantUseCase(const _FakeRepository()),
      summarizePurchase: SummarizePurchaseUseCase(const _FakeRepository()),
    );
    addTearDown(bloc.close);

    const BookAssistantNavigationData navigationData =
        BookAssistantNavigationData(
      purchaseId: 'purchase-1',
      question: 'Important points from Global English',
      book: book,
    );
    bloc.add(const BookAssistantStarted(navigationData));

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<BookAssistantLoading>(),
        isA<BookAssistantLoaded>()
            .having(
              (BookAssistantLoaded state) => state.pendingQuestion,
              'question',
              navigationData.question,
            )
            .having(
              (BookAssistantLoaded state) => state.isAnswering,
              'answering',
              isTrue,
            ),
        isA<BookAssistantLoaded>()
            .having(
              (BookAssistantLoaded state) => state.response?.question,
              'question',
              navigationData.question,
            )
            .having(
              (BookAssistantLoaded state) => state.response?.answer,
              'summary',
              'Important summary',
            )
            .having(
          (BookAssistantLoaded state) => state.selectedBooks,
          'selected book',
          <AssistantBook>[book],
        ),
      ]),
    );
  });
}

class _FakeRepository extends BookAssistantRepository {
  const _FakeRepository();

  @override
  Future<Result<List<AssistantBook>>> getSuggestedBooks() async =>
      const Success<List<AssistantBook>>(<AssistantBook>[]);

  @override
  Future<Result<String>> summarize({required String purchaseId}) async {
    expect(purchaseId, 'purchase-1');
    return const Success<String>('Important summary');
  }

  @override
  Future<Result<AssistantResponse>> ask({
    required String question,
    required List<AssistantBook> books,
  }) async =>
      Success<AssistantResponse>(
        AssistantResponse(
            question: question, answer: 'Mock answer', books: books),
      );
}
