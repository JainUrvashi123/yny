import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class FetchCart extends CartEvent {}

class RemoveFromCart extends CartEvent {
  final String cartId;

  const RemoveFromCart({required this.cartId});

  @override
  List<Object> get props => [cartId];
}

class UpdateCartQuantity extends CartEvent {
  final String cartId;
  final int quantity;

  const UpdateCartQuantity({required this.cartId, required this.quantity});

  @override
  List<Object> get props => [cartId, quantity];
}

class ClearCart extends CartEvent {}

class RemoveSelectedFromCart extends CartEvent {
  final List<String> cartIds;

  const RemoveSelectedFromCart({required this.cartIds});

  @override
  List<Object> get props => [cartIds];
}
