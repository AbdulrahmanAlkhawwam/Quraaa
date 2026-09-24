import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/use_cases/use_case.dart';
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
  FutureEither<List<AssistantBook>> getSuggestedBooks() async =>
      const Right<Failure, List<AssistantBook>>(<AssistantBook>[]);

  @override
  FutureEither<String> summarize({required String purchaseId}) async {
    expect(purchaseId, 'purchase-1');
    return const Right('Important summary');
  }

  @override
  FutureEither<AssistantResponse> ask({
    required String question,
    required List<AssistantBook> books,
  }) async =>
      Right(
        AssistantResponse(
            question: question, answer: 'Mock answer', books: books),
      );
}
