import 'dart:convert';

import '../../../../core/services/storage_service.dart';
import '../../domain/entities/purchased_book.dart';
import '../models/purchased_book_model.dart';

typedef PurchaseCacheScopeProvider = String Function();

/// Last successfully fetched purchase list, kept per signed-in user (the
/// scope) so the library still opens offline.
abstract class PurchasesLocalDataSource {
  bool get hasCache;

  Future<void> save(List<PurchasedBook> books);

  /// Cached books whose title or author contains [query] (case-insensitive).
  /// An unreadable cache reads as empty.
  List<PurchasedBookModel> load({String query = ''});
}

class PurchasesLocalDataSourceImpl implements PurchasesLocalDataSource {
  const PurchasesLocalDataSourceImpl(this._storage, this._scopeProvider);

  final StorageService _storage;
  final PurchaseCacheScopeProvider _scopeProvider;

  String get _cacheKey {
    final String scope = _scopeProvider().trim();
    return 'purchased_books.v1.${scope.isEmpty ? 'anonymous' : scope}';
  }

  @override
  bool get hasCache => _storage.contains(_cacheKey);

  @override
  Future<void> save(List<PurchasedBook> books) async {
    await _storage.setString(
      _cacheKey,
      jsonEncode(
        books.map(PurchasedBookModel.toCacheJson).toList(growable: false),
      ),
    );
  }

  @override
  List<PurchasedBookModel> load({String query = ''}) {
    final String? raw = _storage.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return const <PurchasedBookModel>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <PurchasedBookModel>[];
      final List<PurchasedBookModel> books = decoded
          .whereType<Map>()
          .map(
            (Map value) => PurchasedBookModel.fromCacheJson(
              Map<String, dynamic>.from(value),
            ),
          )
          .where((PurchasedBookModel book) => book.purchaseId.isNotEmpty)
          .toList(growable: false);
      final String normalized = query.trim().toLowerCase();
      if (normalized.isEmpty) return books;
      return books
          .where(
            (PurchasedBookModel book) =>
                book.title.toLowerCase().contains(normalized) ||
                book.author.toLowerCase().contains(normalized),
          )
          .toList(growable: false);
    } catch (_) {
      return const <PurchasedBookModel>[];
    }
  }
}
