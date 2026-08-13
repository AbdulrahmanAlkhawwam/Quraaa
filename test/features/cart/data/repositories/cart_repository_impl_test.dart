import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:quraaa/features/cart/data/models/cart_response_model.dart';
import 'package:quraaa/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:quraaa/features/cart/domain/entities/cart_item.dart';

class _MockCartRemoteDataSource extends Mock
    implements CartRemoteDataSource {}

void main() {
  late _MockCartRemoteDataSource remoteDataSource;
  late CartRepositoryImpl repository;

  const CartResponseModel response = CartResponseModel(
    cartId: 'cart-id',
    status: 0,
    items: <CartResponseItemModel>[
      CartResponseItemModel(
        listingId: 'listing-1',
        quantity: 2,
        unitPrice: 12.5,
        lineTotal: 25,
      ),
      CartResponseItemModel(
        listingId: 'listing-2',
        quantity: 0,
        unitPrice: 9,
        lineTotal: 0,
      ),
    ],
    totalAmount: 25,
    itemCount: 2,
  );

  setUp(() {
    remoteDataSource = _MockCartRemoteDataSource();
    repository = CartRepositoryImpl(remoteDataSource);
  });

  test('maps the API cart response into cart UI entities', () async {
    when(() => remoteDataSource.getCart()).thenAnswer((_) async => response);

    final Result result = await repository.getCart();

    expect(result, isA<Success>());
    final summary = (result as Success).value;
    expect(summary.total, 25);
    expect(summary.items.first.id, 'listing-1');
    expect(summary.items.first.unitPrice, 12.5);
    expect(summary.items.last.status, CartItemStatus.unavailable);
  });

  test('sends quantity updates using the listing ID', () async {
    when(
      () => remoteDataSource.updateQuantity(listingId: 'listing-1', quantity: 3),
    ).thenAnswer((_) async => response);

    await repository.updateQuantity(itemId: 'listing-1', quantity: 3);

    verify(
      () => remoteDataSource.updateQuantity(listingId: 'listing-1', quantity: 3),
    ).called(1);
  });
}
