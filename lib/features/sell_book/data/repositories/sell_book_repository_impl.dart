import '../../domain/entities/sell_book.dart';
import '../../domain/repositories/sell_book_repository.dart';
import '../datasources/sell_book_mock_remote_data_source.dart';

class SellBookRepositoryImpl implements SellBookRepository {
  const SellBookRepositoryImpl(this._remote);
  final SellBookMockRemoteDataSource _remote;
  @override Future<SellBookPreview?> findByIsbn(String isbn) => _remote.findByIsbn(isbn);
  @override Future<void> submit(SellBookDraft draft, {required bool saveAsDraft}) => _remote.submit(draft, saveAsDraft: saveAsDraft);
}
