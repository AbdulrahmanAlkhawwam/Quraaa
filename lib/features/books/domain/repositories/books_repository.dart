import '../entities/book.dart';

abstract interface class BooksRepository {
  Future<List<Book>> getBooks({String query, BookFormat? format});
}
