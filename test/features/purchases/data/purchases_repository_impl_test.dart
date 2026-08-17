import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/core/services/storage_service.dart';
import 'package:quraaa/features/purchases/data/purchases_local_data_source.dart';
import 'package:quraaa/features/purchases/data/purchases_remote_data_source.dart';
import 'package:quraaa/features/purchases/data/purchases_repository_impl.dart';
import 'package:quraaa/features/purchases/data/secure_purchase_book_data_source.dart';
import 'package:quraaa/features/purchases/domain/purchases.dart';

class _MockRemote extends Mock implements PurchasesRemoteDataSource {}

class _MockSecureBooks extends Mock implements SecurePurchaseBookDataSource {}

void main() {
  test('falls back to the cached purchased list when the network fails',
      () async {
    final _MockRemote remote = _MockRemote();
    final PurchasesLocalDataSource local = PurchasesLocalDataSource(
      _MemoryStorage(),
      () => 'user-1',
    );
    final PurchasesRepository repository = PurchasesRepositoryImpl(
      remote,
      local,
      _MockSecureBooks(),
    );
    const PurchasedBook book = PurchasedBook(
      purchaseId: 'purchase-1',
      bookId: 'book-1',
      title: 'Cached Book',
      author: 'Author',
      coverImageUrl: '',
      purchasedAt: null,
      digital: true,
    );
    when(() => remote.getLibrary(query: '')).thenAnswer(
      (_) async => const <PurchasedBook>[book],
    );

    List<PurchasedBook>? onlineBooks;
    (await repository.getLibrary()).fold(
      (_) {},
      (List<PurchasedBook> value) => onlineBooks = value,
    );
    expect(onlineBooks?.single, book);

    when(() => remote.getLibrary(query: '')).thenThrow(Exception('offline'));
    final Result<List<PurchasedBook>> cached = await repository.getLibrary();

    List<PurchasedBook>? cachedBooks;
    cached.fold(
      (_) {},
      (List<PurchasedBook> value) => cachedBooks = value,
    );
    expect(cachedBooks?.single, book);
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
