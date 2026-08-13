import '../../domain/entities/book.dart';
import '../../domain/repositories/books_repository.dart';
import '../datasources/books_mock_remote_data_source.dart';

class BooksRepositoryImpl implements BooksRepository {
  const BooksRepositoryImpl(this._remoteDataSource);

  final BooksMockRemoteDataSource _remoteDataSource;

  @override
  Future<List<Book>> getBooks({String query = '', BookFormat? format}) async {
    final List<Book> books = await _remoteDataSource.fetchBooks();
    final String normalizedQuery = query.trim().toLowerCase();
    return books.where((Book book) {
      final bool matchesQuery = normalizedQuery.isEmpty ||
          book.title.toLowerCase().contains(normalizedQuery) ||
          book.subtitle.toLowerCase().contains(normalizedQuery);
      return matchesQuery && (format == null || book.format == format);
    }).toList(growable: false);
  }
}
