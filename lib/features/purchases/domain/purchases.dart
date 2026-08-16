import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../core/architecture/result.dart';

class PurchasedBook extends Equatable {
  const PurchasedBook({
    required this.purchaseId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.purchasedAt,
    required this.digital,
    this.description = '',
    this.language = '',
    this.isbn = '',
    this.categoryId = '',
  });

  final String purchaseId;
  final String bookId;
  final String title;
  final String author;
  final String coverImageUrl;
  final DateTime? purchasedAt;
  final bool digital;
  final String description;
  final String language;
  final String isbn;
  final String categoryId;

  @override
  List<Object?> get props => <Object?>[
    purchaseId,
    bookId,
    title,
    author,
    coverImageUrl,
    purchasedAt,
    digital,
    description,
    language,
    isbn,
    categoryId,
  ];
}

abstract class PurchasesRepository {
  Future<Result<List<PurchasedBook>>> getLibrary({String query = ''});

  Future<Result<PurchaseBookSession>> openForReading(String purchaseId);

  Future<Result<PreparedPurchaseBook>> prepareForReading(String purchaseId);
}

/// A short-lived clear-text file required by the existing native PDF renderer.
///
/// The file lives only inside the application sandbox and [dispose] removes it
/// as soon as the reader route is closed. The durable offline cache remains
/// encrypted.
class PreparedPurchaseBook {
  PreparedPurchaseBook({
    required this.path,
    required Future<void> Function() release,
  }) : _release = release;

  final String path;
  final Future<void> Function() _release;
  bool _released = false;

  Future<void> dispose() async {
    if (_released) return;
    _released = true;
    await _release();
  }
}

/// Random-access PDF bytes exposed to the reader without writing a clear-text
/// PDF to disk. Implementations may serve ranges from the network or decrypt
/// them from the private application cache.
abstract class PurchaseBookSession {
  int get fileSize;

  String get sourceName;

  bool get isOffline;

  Future<int> read(Uint8List buffer, int position, int size);

  Future<void> cacheForOffline();

  Future<void> dispose();
}
