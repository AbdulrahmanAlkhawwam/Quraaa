import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';
import '../../domain/use_cases/clear_cart_use_case.dart';
import '../../domain/use_cases/get_cart_use_case.dart';
import '../../domain/use_cases/remove_cart_item_use_case.dart';
import '../../domain/use_cases/update_cart_item_quantity_use_case.dart';

sealed class CartEvent {
  const CartEvent();
}

final class CartStarted extends CartEvent {
  const CartStarted();
}

final class CartQuantityIncreased extends CartEvent {
  const CartQuantityIncreased(this.item);

  final CartItem item;
}

final class CartQuantityDecreased extends CartEvent {
  const CartQuantityDecreased(this.item);

  final CartItem item;
}

final class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.listingId);

  final String listingId;
}

final class CartCleared extends CartEvent {
  const CartCleared();
}

sealed class CartState {
  const CartState();
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  const CartLoaded(this.summary, {this.isUpdating = false});

  final CartSummary summary;
  final bool isUpdating;
}

final class CartFailure extends CartState {
  const CartFailure(this.message);

  final String message;
}

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCartUseCase getCart,
    required UpdateCartItemQuantityUseCase updateQuantity,
    required RemoveCartItemUseCase removeItem,
    required ClearCartUseCase clearCart,
  }) : _getCart = getCart,
       _updateQuantity = updateQuantity,
       _removeItem = removeItem,
       _clearCart = clearCart,
       super(const CartInitial()) {
    on<CartStarted>(_onStarted);
    on<CartQuantityIncreased>(_onQuantityIncreased);
    on<CartQuantityDecreased>(_onQuantityDecreased);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
  }

  final GetCartUseCase _getCart;
  final UpdateCartItemQuantityUseCase _updateQuantity;
  final RemoveCartItemUseCase _removeItem;
  final ClearCartUseCase _clearCart;

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    _emitResult(await _getCart(const NoParams()), emit);
  }

  Future<void> _onQuantityIncreased(
    CartQuantityIncreased event,
    Emitter<CartState> emit,
  ) => _changeQuantity(event.item, 1, emit);

  Future<void> _onQuantityDecreased(
    CartQuantityDecreased event,
    Emitter<CartState> emit,
  ) => _changeQuantity(event.item, -1, emit);

  Future<void> _changeQuantity(
    CartItem item,
    int delta,
    Emitter<CartState> emit,
  ) async {
    _emitUpdating(emit);
    _emitResult(
      await _updateQuantity(
        UpdateCartItemQuantityParams(
          itemId: item.id,
          quantity: (item.quantity + delta).clamp(1, 99).toInt(),
        ),
      ),
      emit,
    );
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    _emitUpdating(emit);
    _emitResult(await _removeItem(RemoveCartItemParams(event.listingId)), emit);
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    _emitUpdating(emit);
    _emitResult(await _clearCart(const NoParams()), emit);
  }

  void _emitUpdating(Emitter<CartState> emit) {
    final CartState current = state;
    if (current is CartLoaded) {
      emit(CartLoaded(current.summary, isUpdating: true));
    }
  }

  void _emitResult(Result<CartSummary> result, Emitter<CartState> emit) {
    switch (result) {
      case Success<CartSummary>(value: final CartSummary summary):
        emit(CartLoaded(summary));
      case ResultFailure<CartSummary>(message: final String message):
        emit(CartFailure(message));
    }
  }
}
