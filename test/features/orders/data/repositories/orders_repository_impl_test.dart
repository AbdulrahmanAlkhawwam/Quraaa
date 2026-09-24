import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/core/errors/exceptions.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/features/orders/data/data_sources/orders_remote_data_source.dart';
import 'package:quraaa/features/orders/data/models/account_order_model.dart';
import 'package:quraaa/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:quraaa/features/orders/domain/entities/account_order.dart';

class _MockRemote extends Mock implements OrdersRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late OrdersRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = OrdersRepositoryImpl(remote);
  });

  test('my orders are returned as they come from the backend', () async {
    when(
      () => remote.getMyOrders(pageNumber: 1),
    ).thenAnswer((_) async => const <AccountOrderModel>[]);

    final Either<Failure, List<AccountOrder>> result = await repository
        .getMyOrders();

    expect(result.getOrElse((_) => fail('expected Right')), isEmpty);
  });

  test('a cancelled order returns unit', () async {
    when(
      () => remote.cancelOrder('order-1', reason: 'changed my mind'),
    ).thenAnswer((_) async {});

    expect(
      await repository.cancelOrder('order-1', reason: 'changed my mind'),
      const Right<Failure, Unit>(unit),
    );
  });

  test('a refused cancellation becomes a typed failure', () async {
    when(() => remote.cancelOrder('order-1', reason: null)).thenThrow(
      const ConflictException(message: 'order already shipped'),
    );

    final Either<Failure, Unit> result = await repository.cancelOrder(
      'order-1',
    );

    final Failure failure = result.getLeft().toNullable()!;
    expect(failure, isA<ConflictFailure>());
    expect(failure.message, 'order already shipped');
  });

  test('seller orders pass the fulfillment filter through', () async {
    when(
      () => remote.getSellerOrders(pageNumber: 1, fulfillmentStatus: 0),
    ).thenAnswer((_) async => const <AccountOrderModel>[]);

    await repository.getSellerOrders(fulfillmentStatus: 0);

    verify(
      () => remote.getSellerOrders(pageNumber: 1, fulfillmentStatus: 0),
    ).called(1);
  });
}
