import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../domain/entities/account_order.dart';
import '../../domain/entities/order_checkout_context.dart';
import '../../domain/repositories/orders_repository.dart';

enum AccountOrdersMode { purchases, sales }

class AccountOrdersState extends Equatable {
  const AccountOrdersState({
    this.loading = false,
    this.orders = const <AccountOrder>[],
    this.error,
    this.salesFilter,
  });

  final bool loading;
  final List<AccountOrder> orders;
  final String? error;
  final int? salesFilter;

  AccountOrdersState copyWith({
    bool? loading,
    List<AccountOrder>? orders,
    String? error,
    bool clearError = false,
    int? salesFilter,
    bool clearSalesFilter = false,
  }) {
    return AccountOrdersState(
      loading: loading ?? this.loading,
      orders: orders ?? this.orders,
      error: clearError ? null : error ?? this.error,
      salesFilter: clearSalesFilter ? null : salesFilter ?? this.salesFilter,
    );
  }

  @override
  List<Object?> get props => <Object?>[loading, orders, error, salesFilter];
}

class AccountOrdersCubit extends Cubit<AccountOrdersState> {
  AccountOrdersCubit(this._repository, {required this.mode})
      : super(
          AccountOrdersState(
            salesFilter: mode == AccountOrdersMode.sales ? 2 : null,
          ),
        );

  final OrdersRepository _repository;
  final AccountOrdersMode mode;
  Future<OrderCheckoutContext?> getShippingContext() async {
    if (state.loading || mode != AccountOrdersMode.purchases) return null;
    emit(state.copyWith(loading: true, clearError: true));
    final Result<OrderCheckoutContext> result =
        await _repository.getCheckoutContext();
    if (isClosed) return null;
    OrderCheckoutContext? checkoutContext;
    String? error;
    result.fold(
      (failure) => error = failure.message,
      (value) => checkoutContext = value,
    );
    emit(state.copyWith(
        loading: false, error: error, clearError: error == null));
    return checkoutContext;
  }

  Future<bool> updateShippingLocation(
    AccountOrder order,
    OrderCheckoutLocation location,
  ) async {
    if (state.loading || mode != AccountOrdersMode.purchases) return false;
    emit(state.copyWith(loading: true, clearError: true));
    final Result<AccountOrder> result =
        await _repository.updateShippingLocation(
      orderId: order.orderId,
      shippingLocationId: location.id,
    );
    if (isClosed) return false;
    AccountOrder? updatedOrder;
    String? error;
    result.fold(
      (failure) => error = failure.message,
      (value) => updatedOrder = value,
    );
    if (error != null) {
      emit(state.copyWith(loading: false, error: error));
      return false;
    }
    final List<AccountOrder> orders = state.orders
        .map((AccountOrder item) =>
            item.orderId == order.orderId ? updatedOrder! : item)
        .toList(growable: false);
    emit(state.copyWith(loading: false, orders: orders, clearError: true));
    return true;
  }

  Future<bool> cancel(AccountOrder order, {String? reason}) async {
    if (state.loading || mode != AccountOrdersMode.purchases) return false;
    emit(state.copyWith(loading: true, clearError: true));
    final Result<void> result = await _repository.cancelOrder(
      order.orderId,
      reason: reason,
    );
    if (isClosed) return false;
    String? error;
    result.fold((failure) => error = failure.message, (_) {});
    if (error != null) {
      emit(state.copyWith(loading: false, error: error));
      return false;
    }
    await load();
    return true;
  }

  Future<void> advance(AccountOrder order, AccountOrderItem item) async {
    if (state.loading || mode != AccountOrdersMode.sales) return;
    emit(state.copyWith(loading: true, clearError: true));
    final Result<void> result = item.fulfillmentStatus == 0
        ? await _repository.markSellerItemProcessing(
            order.orderId,
            item.orderItemId,
          )
        : await _repository.markSellerItemFulfilled(
            order.orderId,
            item.orderItemId,
          );
    if (isClosed) return;
    String? error;
    result.fold((failure) => error = failure.message, (_) {});
    if (error != null) {
      emit(state.copyWith(loading: false, error: error));
      return;
    }
    await load(salesFilter: state.salesFilter);
  }

  Future<void> load({int? salesFilter}) async {
    final int? selectedSalesFilter = mode == AccountOrdersMode.sales
        ? salesFilter ?? state.salesFilter ?? 2
        : null;
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        salesFilter: selectedSalesFilter,
      ),
    );
    final Result<List<AccountOrder>> result =
        mode == AccountOrdersMode.purchases
            ? await _repository.getMyOrders()
            : selectedSalesFilter == 2
                ? await _repository.getSellHistory()
                : await _repository.getSellerOrders(
                    fulfillmentStatus: selectedSalesFilter,
                  );
    if (isClosed) return;
    result.fold(
      (ResultFailure<List<AccountOrder>> failure) => emit(
        state.copyWith(loading: false, error: failure.message),
      ),
      (List<AccountOrder> orders) => emit(
        state.copyWith(loading: false, orders: orders, clearError: true),
      ),
    );
  }
}
