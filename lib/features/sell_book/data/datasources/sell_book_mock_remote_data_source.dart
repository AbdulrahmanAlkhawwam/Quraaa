import '../../domain/entities/sell_book.dart';

/// Temporary mock endpoint. Replace this datasource when the marketplace API lands.
abstract interface class SellBookMockRemoteDataSource {
  Future<SellBookPreview?> findByIsbn(String isbn);
  Future<void> submit(SellBookDraft draft, {required bool saveAsDraft});
}

class SellBookMockRemoteDataSourceImpl implements SellBookMockRemoteDataSource {
  const SellBookMockRemoteDataSourceImpl();
  static const _isbn = '9780306406157';
  @override
  Future<SellBookPreview?> findByIsbn(String isbn) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (isbn.replaceAll(RegExp(r'[^0-9Xx]'), '') != _isbn) return null;
    return const SellBookPreview(
        isbn: '978-0-306-40615-7',
        title: 'Global English Coursebook 10',
        language: 'English',
        publisher: 'Cambridge University',
        author: 'Tim Carter & Katia Carter',
        edition: '10th for 2025',
        coverAsset: 'assets/images/books/global_english_10.png');
  }

  @override
  Future<void> submit(SellBookDraft draft, {required bool saveAsDraft}) =>
      Future<void>.delayed(const Duration(milliseconds: 300));
}
