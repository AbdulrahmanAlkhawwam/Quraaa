import 'dart:convert';

import '../../../core/services/storage_service.dart';
import '../domain/purchases.dart';

typedef PurchaseCacheScopeProvider = String Function();

class PurchasesLocalDataSource {
  const PurchasesLocalDataSource(
    this._storage,
    this._scopeProvider,
  );

  final StorageService _storage;
  final PurchaseCacheScopeProvider _scopeProvider;

  String get _cacheKey {
    final String scope = _scopeProvider().trim();
    return 'purchased_books.v1.${scope.isEmpty ? 'anonymous' : scope}';
  }

  bool get hasCache => _storage.contains(_cacheKey);

  Future<void> save(List<PurchasedBook> books) async {
    await _storage.setString(
      _cacheKey,
      jsonEncode(books.map(_toJson).toList(growable: false)),
    );
  }

  List<PurchasedBook> load({String query = ''}) {
    final String? raw = _storage.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return const <PurchasedBook>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <PurchasedBook>[];
      final List<PurchasedBook> books = decoded
          .whereType<Map>()
          .map(
            (Map value) => _fromJson(Map<String, dynamic>.from(value)),
          )
          .where((PurchasedBook book) => book.purchaseId.isNotEmpty)
          .toList(growable: false);
      final String normalized = query.trim().toLowerCase();
      if (normalized.isEmpty) return books;
      return books
          .where(
            (PurchasedBook book) =>
                book.title.toLowerCase().contains(normalized) ||
                book.author.toLowerCase().contains(normalized),
          )
          .toList(growable: false);
    } catch (_) {
      return const <PurchasedBook>[];
    }
  }

  Map<String, Object?> _toJson(PurchasedBook book) => <String, Object?>{
        'purchaseId': book.purchaseId,
        'bookId': book.bookId,
        'title': book.title,
        'author': book.author,
        'coverImageUrl': book.coverImageUrl,
        'purchasedAt': book.purchasedAt?.toIso8601String(),
        'digital': book.digital,
        'description': book.description,
        'language': book.language,
        'isbn': book.isbn,
        'categoryId': book.categoryId,
      };

  PurchasedBook _fromJson(Map<String, dynamic> json) => PurchasedBook(
        purchaseId: json['purchaseId']?.toString() ?? '',
        bookId: json['bookId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        author: json['author']?.toString() ?? '',
        coverImageUrl: json['coverImageUrl']?.toString() ?? '',
        purchasedAt: DateTime.tryParse(json['purchasedAt']?.toString() ?? ''),
        digital: json['digital'] == true,
        description: json['description']?.toString() ?? '',
        language: json['language']?.toString() ?? '',
        isbn: json['isbn']?.toString() ?? '',
        categoryId: json['categoryId']?.toString() ?? '',
      );
}
