import 'package:equatable/equatable.dart';
import '../../data/models/cart_model.dart';

abstract class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartModel> cartItems;
  final bool isUpdating;
  final String? updatingCartId;

  const CartLoaded({
    required this.cartItems,
    this.isUpdating = false,
    this.updatingCartId,
  });

  @override
  List<Object> get props => [cartItems, isUpdating, updatingCartId ?? ''];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}
