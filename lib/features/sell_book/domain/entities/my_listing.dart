import 'package:equatable/equatable.dart';

class MyListing extends Equatable {
  const MyListing({
    required this.listingId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.price,
    required this.stock,
    required this.condition,
    required this.format,
    required this.status,
  });

  final String listingId;
  final String bookId;
  final String title;
  final String author;
  final String coverImageUrl;
  final double price;
  final int stock;
  final String condition;
  final String format;
  final int status;

  @override
  List<Object?> get props => <Object?>[
        listingId,
        bookId,
        title,
        author,
        coverImageUrl,
        price,
        stock,
        condition,
        format,
        status,
      ];
}
