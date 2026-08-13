import '../entities/sell_book.dart';

abstract interface class SellBookRepository {
  Future<SellBookPreview?> findByIsbn(String isbn);
  Future<void> submit(SellBookDraft draft, {required bool saveAsDraft});
}
