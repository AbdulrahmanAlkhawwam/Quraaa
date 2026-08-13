import '../../domain/entities/book.dart';

/// Temporary in-app endpoint replacement until the books API is available.
abstract interface class BooksMockRemoteDataSource {
  Future<List<Book>> fetchBooks();
}

class BooksMockRemoteDataSourceImpl implements BooksMockRemoteDataSource {
  const BooksMockRemoteDataSourceImpl();

  @override
  Future<List<Book>> fetchBooks() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const <Book>[
      Book(id: '1', title: 'Global English', subtitle: 'Course Book 10', price: '15\$', format: BookFormat.audio, coverAsset: 'assets/images/books/global_english_10.png'),
      Book(id: '2', title: 'Global English', subtitle: 'Course Book 11', price: '13.5\$', format: BookFormat.ebook, coverAsset: 'assets/images/books/global_english_11.png'),
      Book(id: '3', title: 'Global English', subtitle: 'Course Book 10', price: '15\$', format: BookFormat.free, coverAsset: 'assets/images/books/global_english_10.png'),
      Book(id: '4', title: 'Global English', subtitle: 'Learner’s Book 8', price: '9\$', format: BookFormat.used, coverAsset: 'assets/images/books/learners_book_8.png'),
      Book(id: '5', title: 'Global English', subtitle: 'Course Book 11', price: '13.5\$', format: BookFormat.ebook, coverAsset: 'assets/images/books/global_english_11.png'),
      Book(id: '6', title: 'Global English', subtitle: 'Learner’s Book 8', price: '9\$', format: BookFormat.used, coverAsset: 'assets/images/books/learners_book_8.png'),
    ];
  }
}
