import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/purchases/domain/purchases.dart';
import 'package:quraaa/features/purchases/presentation/purchases_cubit.dart';

class _MockPurchasesRepository extends Mock implements PurchasesRepository {}

void main() {
  late _MockPurchasesRepository repository;
  late PurchasesCubit cubit;
  const PurchasedBook book = PurchasedBook(
    purchaseId: 'purchase-1',
    bookId: 'book-1',
    title: 'Book',
    author: 'Author',
    coverImageUrl: '',
    purchasedAt: null,
    digital: true,
  );

  setUp(() {
    repository = _MockPurchasesRepository();
    cubit = PurchasesCubit(repository);
  });

  tearDown(() => cubit.close());

  test('marks a book readable only after its encrypted download completes',
      () async {
    when(() => repository.getLibrary(query: '')).thenAnswer(
      (_) async => const Success<List<PurchasedBook>>(<PurchasedBook>[book]),
    );
    when(() => repository.isAvailableOffline('purchase-1')).thenAnswer(
      (_) async => const Success<bool>(false),
    );
    when(() => repository.downloadForOffline('purchase-1')).thenAnswer(
      (_) async => const Success<void>(null),
    );

    await cubit.load();
    expect(cubit.state.isOffline(book), isFalse);

    expect(await cubit.download(book), isTrue);
    expect(cubit.state.isOffline(book), isTrue);

    cubit.open(book);
    expect(cubit.state.openedPurchaseId, 'purchase-1');
    expect(cubit.state.openSerial, 1);
  });
}
