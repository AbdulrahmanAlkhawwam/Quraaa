import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/assistant_book.dart';
import '../entities/assistant_response.dart';

abstract class BookAssistantRepository {
  const BookAssistantRepository();

  FutureEither<List<AssistantBook>> getSuggestedBooks();

  FutureEither<String> summarize({required String purchaseId});

  /// Implementations without a translation backend keep the default failure.
  FutureEither<String> translate({
    required String purchaseId,
    required int pageNumber,
    required String targetLanguage,
  }) async => const Left(
    OperationFailedFailure(message: 'Translation is unavailable.'),
  );

  /// Implementations without an explanation backend keep the default failure.
  FutureEither<String> explain({
    required String purchaseId,
    required String selectedText,
  }) async => const Left(
    OperationFailedFailure(message: 'Explanation is unavailable.'),
  );

  FutureEither<AssistantResponse> ask({
    required String question,
    required List<AssistantBook> books,
  });
}
