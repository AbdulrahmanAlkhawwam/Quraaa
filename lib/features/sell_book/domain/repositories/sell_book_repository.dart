import '../../../../core/architecture/result.dart';
import '../entities/sell_book.dart';

abstract interface class SellBookRepository {
  Future<SellBookPreview?> findByIsbn(String isbn);

  Future<Result<String>> submit(SellBookDraft draft);
}
