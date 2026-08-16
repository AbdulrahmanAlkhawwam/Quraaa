import '../../../../core/architecture/result.dart';
import '../entities/assistant_book.dart';
import '../entities/assistant_response.dart';

abstract class BookAssistantRepository {
  const BookAssistantRepository();

  Future<Result<List<AssistantBook>>> getSuggestedBooks();

  Future<Result<String>> summarize({required String purchaseId});

  Future<Result<String>> translate({
    required String purchaseId,
    required int pageNumber,
    required String targetLanguage,
  }) async =>
      const ResultFailure<String>('Translation is unavailable.');

  Future<Result<String>> explain({
    required String purchaseId,
    required String selectedText,
  }) async =>
      const ResultFailure<String>('Explanation is unavailable.');

  Future<Result<AssistantResponse>> ask({
    required String question,
    required List<AssistantBook> books,
  });
}
