import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/architecture/result.dart';
import 'package:quraaa/features/orders/domain/entities/account_order.dart';
import 'package:quraaa/features/orders/domain/repositories/orders_repository.dart';
import 'package:quraaa/features/orders/presentation/cubit/account_orders_cubit.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late _MockOrdersRepository repository;

  setUp(() {
    repository = _MockOrdersRepository();
  });

  test('sales mode opens completed sell history by default', () async {
    when(() => repository.getSellHistory()).thenAnswer(
      (_) async => const Success<List<AccountOrder>>(<AccountOrder>[]),
    );
    final AccountOrdersCubit cubit = AccountOrdersCubit(
      repository,
      mode: AccountOrdersMode.sales,
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.salesFilter, 2);
    verify(() => repository.getSellHistory()).called(1);
    verifyNever(
      () => repository.getSellerOrders(
        fulfillmentStatus: any(named: 'fulfillmentStatus'),
      ),
    );
  });

  test('processing filter loads active seller orders', () async {
    when(
      () => repository.getSellerOrders(fulfillmentStatus: 1),
    ).thenAnswer(
      (_) async => const Success<List<AccountOrder>>(<AccountOrder>[]),
    );
    final AccountOrdersCubit cubit = AccountOrdersCubit(
      repository,
      mode: AccountOrdersMode.sales,
    );
    addTearDown(cubit.close);

    await cubit.load(salesFilter: 1);

    expect(cubit.state.salesFilter, 1);
    verify(() => repository.getSellerOrders(fulfillmentStatus: 1)).called(1);
  });
}
