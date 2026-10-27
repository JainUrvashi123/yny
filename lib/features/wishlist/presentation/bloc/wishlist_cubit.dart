import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../data/models/wishlist_model.dart';

abstract class WishlistState {}

class WishlistInitial extends WishlistState {}
class WishlistLoading extends WishlistState {}
class WishlistLoaded extends WishlistState {
  final List<WishlistItemModel> items;
  WishlistLoaded(this.items);
}
class WishlistError extends WishlistState {
  final String message;
  WishlistError(this.message);
}

class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRemoteDataSource dataSource;

  WishlistCubit(this.dataSource) : super(WishlistInitial());

  Future<void> fetchWishlist() async {
    emit(WishlistLoading());
    try {
      final items = await dataSource.getWishlist();
      emit(WishlistLoaded(items));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> removeWishlist(String wishlistId) async {
    try {
      await dataSource.removeWishlist(wishlistId: wishlistId);
      await fetchWishlist(); // Refresh to ensure sync
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> addToWishlist(String stockId) async {
    try {
      await dataSource.addToWishlist(stockId: stockId);
      await fetchWishlist(); // Refresh to ensure sync
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }
}
