import '../../domain/entities/library_book_entity.dart';
import '../cubit/library_details_state.dart';

/// UI data passed to the author details screen until its API is connected.
class AuthorDetailsNavigationData {
  const AuthorDetailsNavigationData({
    required this.author,
    this.works = const <LibraryBookEntity>[],
    this.description = '',
    this.rating = 0,
    this.reviewCount = 0,
  });

  final LibraryAuthorViewModel author;
  final List<LibraryBookEntity> works;
  final String description;
  final double rating;
  final int reviewCount;
}

/// UI data passed to the book details screen until its API is connected.
class BookDetailsNavigationData {
  const BookDetailsNavigationData({required this.book, this.purchaseId});

  final LibraryBookEntity book;
  final String? purchaseId;
}
