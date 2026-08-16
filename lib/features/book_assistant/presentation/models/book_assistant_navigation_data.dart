import '../../domain/entities/assistant_book.dart';

class BookAssistantNavigationData {
  const BookAssistantNavigationData({
    required this.purchaseId,
    required this.question,
    required this.book,
  });

  final String purchaseId;
  final String question;
  final AssistantBook book;
}
