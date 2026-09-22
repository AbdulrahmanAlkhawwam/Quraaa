import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/services/storage_service.dart';
import 'package:quraaa/features/purchases/purchases.dart';

class _MockRemote extends Mock implements PurchasesRemoteDataSource {}

class _MockSecureBooks extends Mock implements SecurePurchaseBookDataSource {}

void main() {
  late _MockRemote remote;
  late PurchasesRepository repository;

  const PurchasedBookModel model = PurchasedBookModel(
    purchaseId: 'purchase-1',
    bookId: 'book-1',
    title: 'Cached Book',
    author: 'Author',
    coverImageUrl: '',
    purchasedAt: null,
    digital: true,
  );

  setUp(() {
    remote = _MockRemote();
    repository = PurchasesRepositoryImpl(
      remote,
      PurchasesLocalDataSourceImpl(_MemoryStorage(), () => 'user-1'),
      _MockSecureBooks(),
    );
  });

  List<PurchasedBook> booksOf(Either<Failure, List<PurchasedBook>> result) =>
      result.getOrElse((_) => fail('expected Right'));

  test('falls back to the cached purchased list when the network fails',
      () async {
    when(
      () => remote.getLibrary(query: ''),
    ).thenAnswer((_) async => const <PurchasedBookModel>[model]);
    expect(booksOf(await repository.getLibrary()).single, model.toEntity());

    when(() => remote.getLibrary(query: '')).thenThrow(Exception('offline'));

    expect(booksOf(await repository.getLibrary()).single, model.toEntity());
  });

  test('hands plain entities, not models, to the layers above', () async {
    when(
      () => remote.getLibrary(query: ''),
    ).thenAnswer((_) async => const <PurchasedBookModel>[model]);

    final PurchasedBook book = booksOf(await repository.getLibrary()).single;

    expect(book, isNot(isA<PurchasedBookModel>()));
  });

  test('fails when the network fails and nothing is cached yet', () async {
    when(() => remote.getLibrary(query: '')).thenThrow(Exception('offline'));

    expect((await repository.getLibrary()).isLeft(), isTrue);
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
