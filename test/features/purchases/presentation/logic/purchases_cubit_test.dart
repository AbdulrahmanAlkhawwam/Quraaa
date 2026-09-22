import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/purchases/purchases.dart';

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
    cubit = PurchasesCubit(
      getPurchasedBooks: GetPurchasedBooksUseCase(repository),
      isAvailableOffline: IsPurchaseAvailableOfflineUseCase(repository),
      downloadForOffline: DownloadPurchaseForOfflineUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  test('marks a book readable only after its encrypted download completes',
      () async {
    when(
      () => repository.getLibrary(query: ''),
    ).thenAnswer((_) async => const Right(<PurchasedBook>[book]));
    when(
      () => repository.isAvailableOffline('purchase-1'),
    ).thenAnswer((_) async => const Right(false));
    when(
      () => repository.downloadForOffline('purchase-1'),
    ).thenAnswer((_) async => const Right(unit));

    await cubit.load();
    expect(cubit.state.isOffline(book), isFalse);

    expect(await cubit.download(book), isTrue);
    expect(cubit.state.isOffline(book), isTrue);

    cubit.open(book);
    expect(cubit.state.openedPurchaseId, 'purchase-1');
    expect(cubit.state.openSerial, 1);
  });

  test('a failed download leaves the book online-only with the message',
      () async {
    when(
      () => repository.getLibrary(query: ''),
    ).thenAnswer((_) async => const Right(<PurchasedBook>[book]));
    when(
      () => repository.isAvailableOffline('purchase-1'),
    ).thenAnswer((_) async => const Right(false));
    when(() => repository.downloadForOffline('purchase-1')).thenAnswer(
      (_) async => const Left(InsufficientStorageFailure(message: 'disk full')),
    );
    await cubit.load();

    expect(await cubit.download(book), isFalse);
    expect(cubit.state.isOffline(book), isFalse);
    expect(cubit.state.isDownloading(book), isFalse);
    expect(cubit.state.error, 'disk full');
  });
}
