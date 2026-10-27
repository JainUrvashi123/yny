import '../models/cart_model.dart';
import '../datasources/cart_remote_datasource.dart';

abstract class CartRepository {
  Future<List<CartModel>> getCart();
  Future<List<CartModel>> removeFromCart(String cartId);
  Future<List<CartModel>> updateCartQuantity(String cartId, int quantity);
  Future<bool> sendOrder(List<String> cartIds, {String name = '', String email = '', String message = ''});
}

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CartModel>> getCart() async {
    return await remoteDataSource.getCart();
  }

  @override
  Future<List<CartModel>> removeFromCart(String cartId) async {
    return await remoteDataSource.removeFromCart(cartId);
  }

  @override
  Future<List<CartModel>> updateCartQuantity(String cartId, int quantity) async {
    return await remoteDataSource.updateCartQuantity(cartId, quantity);
  }

  @override
  Future<bool> sendOrder(List<String> cartIds, {String name = '', String email = '', String message = ''}) async {
    return await remoteDataSource.sendOrder(cartIds, name: name, email: email, message: message);
  }
}
