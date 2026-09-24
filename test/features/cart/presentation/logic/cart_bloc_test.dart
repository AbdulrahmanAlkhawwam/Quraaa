import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/cart/domain/entities/cart_item.dart';
import 'package:quraaa/features/cart/domain/entities/cart_summary.dart';
import 'package:quraaa/features/cart/domain/repositories/cart_repository.dart';
import 'package:quraaa/features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'package:quraaa/features/cart/domain/use_cases/get_cart_use_case.dart';
import 'package:quraaa/features/cart/domain/use_cases/remove_cart_item_use_case.dart';
import 'package:quraaa/features/cart/domain/use_cases/update_cart_item_quantity_use_case.dart';
import 'package:quraaa/features/cart/presentation/logic/cart_bloc.dart';

class _MockCartRepository extends Mock implements CartRepository {}

void main() {
  late _MockCartRepository repository;
  late CartBloc bloc;

  const CartItem item = CartItem(
    id: 'listing-1',
    title: 'Book',
    subtitle: 'Author',
    fileSize: '',
    imageUrl: '',
    unitPrice: 10,
    quantity: 2,
  );
  const CartSummary summary = CartSummary(
    userName: '',
    avatarUrl: '',
    items: <CartItem>[item],
    couponCode: '',
    couponApplied: false,
    subtotal: 20,
    fatPercent: 0,
    delivery: 0,
    discountPercent: 0,
    total: 20,
  );

  setUp(() {
    repository = _MockCartRepository();
    bloc = CartBloc(
      getCart: GetCartUseCase(repository),
      updateQuantity: UpdateCartItemQuantityUseCase(repository),
      removeItem: RemoveCartItemUseCase(repository),
      clearCart: ClearCartUseCase(repository),
    );
  });

  tearDown(() => bloc.close());

  test('loads the cart on start', () async {
    when(
      () => repository.getCart(),
    ).thenAnswer((_) async => const Right(summary));

    bloc.add(const CartStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[isA<CartLoading>(), isA<CartLoaded>()]),
    );
  });

  test('a failed load surfaces the message', () async {
    when(() => repository.getCart()).thenAnswer(
      (_) async => const Left(NoInternetFailure(message: 'offline')),
    );

    bloc.add(const CartStarted());

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<CartLoading>(),
        isA<CartFailure>().having(
          (CartFailure state) => state.message,
          'message',
          'offline',
        ),
      ]),
    );
  });

  test('increasing a quantity sends the new value', () async {
    when(
      () => repository.getCart(),
    ).thenAnswer((_) async => const Right(summary));
    when(
      () => repository.updateQuantity(listingId: 'listing-1', quantity: 3),
    ).thenAnswer((_) async => const Right(summary));
    bloc.add(const CartStarted());
    await bloc.stream.firstWhere((CartState state) => state is CartLoaded);

    bloc.add(const CartQuantityIncreased(item));

    await expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<CartLoaded>().having(
          (CartLoaded state) => state.isUpdating,
          'isUpdating',
          isTrue,
        ),
        isA<CartLoaded>().having(
          (CartLoaded state) => state.isUpdating,
          'isUpdating',
          isFalse,
        ),
      ]),
    );
    verify(
      () => repository.updateQuantity(listingId: 'listing-1', quantity: 3),
    ).called(1);
  });
}
