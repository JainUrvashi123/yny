import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc({required this.repository}) : super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
    on<RemoveSelectedFromCart>(_onRemoveSelectedFromCart);
  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await repository.getCart();
      emit(CartLoaded(cartItems: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoaded(cartItems: currentState.cartItems, isUpdating: true, updatingCartId: event.cartId));
    } else {
      emit(CartLoading());
    }
    try {
      final items = await repository.removeFromCart(event.cartId);
      emit(CartLoaded(cartItems: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateCartQuantity(UpdateCartQuantity event, Emitter<CartState> emit) async {
    // Optionally preserve the current list state while updating
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoaded(cartItems: currentState.cartItems, isUpdating: true, updatingCartId: event.cartId));
    } else {
      emit(CartLoading());
    }
    
    try {
      final items = await repository.updateCartQuantity(event.cartId, event.quantity);
      emit(CartLoaded(cartItems: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoaded(cartItems: currentState.cartItems, isUpdating: true));
      try {
        final futures = currentState.cartItems.map((item) => repository.removeFromCart(item.cartId ?? ''));
        await Future.wait(futures);
        final finalItems = await repository.getCart();
        emit(CartLoaded(cartItems: finalItems));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onRemoveSelectedFromCart(RemoveSelectedFromCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(CartLoaded(cartItems: currentState.cartItems, isUpdating: true));
      try {
        final futures = event.cartIds.map((cartId) => repository.removeFromCart(cartId));
        await Future.wait(futures);
        final finalItems = await repository.getCart();
        emit(CartLoaded(cartItems: finalItems));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }
}
