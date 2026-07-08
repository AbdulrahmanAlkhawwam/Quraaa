import '../../../../core/architecture/result.dart';
import '../entities/assistant_book.dart';
import '../entities/assistant_response.dart';

abstract class BookAssistantRepository {
  const BookAssistantRepository();

  Future<Result<List<AssistantBook>>> getSuggestedBooks();

  Future<Result<AssistantResponse>> ask({
    required String question,
    required List<AssistantBook> books,
  });
}

