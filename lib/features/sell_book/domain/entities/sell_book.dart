import 'package:equatable/equatable.dart';

enum SellBookMethod { isbn, library, own }

enum SellBookCondition { newBook, used, refurbished }

class SellBookPreview extends Equatable {
  const SellBookPreview(
      {required this.isbn,
      required this.title,
      required this.language,
      required this.publisher,
      required this.author,
      required this.edition,
      required this.coverAsset});
  final String isbn;
  final String title;
  final String language;
  final String publisher;
  final String author;
  final String edition;
  final String coverAsset;
  @override
  List<Object> get props =>
      <Object>[isbn, title, language, publisher, author, edition, coverAsset];
}

class SellBookImage extends Equatable {
  const SellBookImage(
      {required this.path, required this.name, required this.bytes});
  final String path;
  final String name;
  final int bytes;
  @override
  List<Object> get props => <Object>[path, name, bytes];
}

class SellBookDraft extends Equatable {
  const SellBookDraft(
      {required this.method,
      required this.price,
      required this.condition,
      required this.images,
      this.isbn,
      this.preview,
      this.title,
      this.libraryBookId});
  final SellBookMethod method;
  final String? isbn;
  final SellBookPreview? preview;
  final String? libraryBookId;
  final String? title;
  final double price;
  final SellBookCondition condition;
  final List<SellBookImage> images;
  @override
  List<Object?> get props => <Object?>[
        method,
        isbn,
        preview,
        libraryBookId,
        title,
        price,
        condition,
        images
      ];
}
