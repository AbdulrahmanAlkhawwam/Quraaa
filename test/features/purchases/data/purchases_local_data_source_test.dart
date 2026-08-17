import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/services/storage_service.dart';
import 'package:quraaa/features/purchases/data/purchases_local_data_source.dart';
import 'package:quraaa/features/purchases/domain/purchases.dart';

void main() {
  test('caches purchased-book metadata per user for offline listing', () async {
    final _MemoryStorage storage = _MemoryStorage();
    String userId = 'user-1';
    final PurchasesLocalDataSource local = PurchasesLocalDataSource(
      storage,
      () => userId,
    );
    final List<PurchasedBook> books = <PurchasedBook>[
      PurchasedBook(
        purchaseId: 'purchase-1',
        bookId: 'book-1',
        title: 'Offline Book',
        author: 'Author',
        coverImageUrl: 'https://example.com/cover.jpg',
        purchasedAt: DateTime.utc(2026, 8, 17),
        digital: true,
      ),
    ];

    await local.save(books);

    expect(local.hasCache, isTrue);
    expect(local.load().single, books.single);
    expect(local.load(query: 'author').single.purchaseId, 'purchase-1');

    userId = 'user-2';
    expect(local.hasCache, isFalse);
    expect(local.load(), isEmpty);
  });
}

class _MemoryStorage extends StorageService {
  final Map<String, Object> values = <String, Object>{};

  @override
  bool contains(String key) => values.containsKey(key);

  @override
  Future<bool> clearAll() async {
    values.clear();
    return true;
  }

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  List<String>? getStringList(String key) => values[key] as List<String>?;

  @override
  Future<bool> remove(String key) async => values.remove(key) != null;

  @override
  Future<bool> setBool(String key, bool value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    values[key] = value;
    return true;
  }
}
