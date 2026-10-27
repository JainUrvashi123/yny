import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItemModel>> getWishlist();
  Future<bool> addToWishlist({required String stockId});
  Future<bool> removeWishlist({required String wishlistId});
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio _dio;
  static const String baseUrl = 'https://ynyjewelsinc.com/m_api/diamond';

  WishlistRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '302'; // Defaulting to 302 for now if not found
  }

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    try {
      final userId = await _getUserId();
      final response = await _dio.post(
        '$baseUrl/get-wish',
        data: {"user_id": userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data;
      if (data != null && data['status'] == 1 && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((e) => WishlistItemModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  @override
  Future<bool> addToWishlist({required String stockId}) async {
    try {
      final userId = await _getUserId();
      final response = await _dio.post(
        '$baseUrl/add-wish',
        data: {"user_id": userId, "stock_id": stockId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data;
      return data != null && data['status'] == 1;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeWishlist({required String wishlistId}) async {
    try {
      final userId = await _getUserId();
      final response = await _dio.post(
        '$baseUrl/remove-wish',
        data: {"user_id": userId, "wishlist_id": wishlistId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data;
      return data != null && data['status'] == 1;
    } catch (e) {
      return false;
    }
  }
}
