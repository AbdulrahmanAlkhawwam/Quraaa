import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/cart_summary.dart';
import '../../domain/use_cases/apply_cart_coupon_use_case.dart';
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
  const CartItemRemoved(this.itemId);

  final String itemId;
}

final class CartCouponSubmitted extends CartEvent {
  const CartCouponSubmitted(this.code);

  final String code;
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
  const CartLoaded(this.summary);

  final CartSummary summary;
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
    required ApplyCartCouponUseCase applyCoupon,
  })  : _getCart = getCart,
        _updateQuantity = updateQuantity,
        _removeItem = removeItem,
        _applyCoupon = applyCoupon,
        super(const CartInitial()) {
    on<CartStarted>(_onStarted);
    on<CartQuantityIncreased>(_onQuantityIncreased);
    on<CartQuantityDecreased>(_onQuantityDecreased);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCouponSubmitted>(_onCouponSubmitted);
  }

  final GetCartUseCase _getCart;
  final UpdateCartItemQuantityUseCase _updateQuantity;
  final RemoveCartItemUseCase _removeItem;
  final ApplyCartCouponUseCase _applyCoupon;

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    _emitResult(await _getCart(const NoParams()), emit);
  }

  Future<void> _onQuantityIncreased(
    CartQuantityIncreased event,
    Emitter<CartState> emit,
  ) async {
    await _changeQuantity(event.item, 1, emit);
  }

  Future<void> _onQuantityDecreased(
    CartQuantityDecreased event,
    Emitter<CartState> emit,
  ) async {
    await _changeQuantity(event.item, -1, emit);
  }

  Future<void> _changeQuantity(
    CartItem item,
    int delta,
    Emitter<CartState> emit,
  ) async {
    _emitResult(
      await _updateQuantity(
        UpdateCartItemQuantityParams(
          itemId: item.id,
          quantity: item.quantity + delta,
        ),
      ),
      emit,
    );
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    _emitResult(
      await _removeItem(RemoveCartItemParams(event.itemId)),
      emit,
    );
  }

  Future<void> _onCouponSubmitted(
    CartCouponSubmitted event,
    Emitter<CartState> emit,
  ) async {
    _emitResult(
      await _applyCoupon(ApplyCartCouponParams(event.code)),
      emit,
    );
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
