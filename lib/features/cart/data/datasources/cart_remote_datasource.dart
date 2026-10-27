import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartModel>> getCart();
  Future<List<CartModel>> removeFromCart(String cartId);
  Future<List<CartModel>> updateCartQuantity(String cartId, int quantity);
  Future<bool> sendOrder(List<String> cartIds, {String name = '', String email = '', String message = ''});
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio _dio;

  CartRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<CartModel>> getCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('user_id') ?? '0';
      final userId = int.tryParse(userIdStr) ?? 0;

      final data = <String, dynamic>{
        "user_id": userId,
      };

      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/diamond/get-cart',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (responseData == null) return [];
      
      Map<String, dynamic> jsonMap;
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        return [];
      }

      final status = jsonMap['status'];
      if (status == 1 || status == '1' || status == true || status == 'success') {
        final List<dynamic> dataList = jsonMap['data'] ?? [];
        return dataList.map((e) => CartModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CartModel>> removeFromCart(String cartId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('user_id') ?? '0';
      final userId = int.tryParse(userIdStr) ?? 0;

      final data = <String, dynamic>{
        "user_id": userId,
        "cart_id": cartId,
      };

      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/diamond/remove-cart',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (responseData == null) return [];
      
      Map<String, dynamic> jsonMap;
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        return [];
      }

      // Even if status is 0 (as shown in the user's Postman screenshot), the API might return the updated cart in 'data'.
      // So we parse the data list as long as it exists.
      if (jsonMap.containsKey('data') && jsonMap['data'] is List) {
        final List<dynamic> dataList = jsonMap['data'];
        return dataList.map((e) => CartModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CartModel>> updateCartQuantity(String cartId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('user_id') ?? '0';
      final userId = int.tryParse(userIdStr) ?? 0;

      final data = <String, dynamic>{
        "user_id": userId,
        "cart_id": cartId,
        "quantity": quantity,
      };

      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/diamond/update-cart-quantity',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (responseData == null) return [];
      
      Map<String, dynamic> jsonMap;
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        return [];
      }

      if (jsonMap.containsKey('data') && jsonMap['data'] is List) {
        final List<dynamic> dataList = jsonMap['data'];
        return dataList.map((e) => CartModel.fromJson(e)).toList();
      } else if (jsonMap.containsKey('data') && jsonMap['data'] is Map && jsonMap['data']['details'] is List) {
        // Fallback if it matches add-cart response format
        final List<dynamic> dataList = jsonMap['data']['details'];
        return dataList.map((e) => CartModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> sendOrder(List<String> cartIds, {String name = '', String email = '', String message = ''}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('user_id') ?? '0';
      final userId = int.tryParse(userIdStr) ?? 0;

      final data = <String, dynamic>{
        "user_id": userId,
        "checkbox_arr": cartIds.join(','),
        "name": name,
        "email": email,
        "message": message,
      };

      print('SEND ORDER REQUEST DATA: $data');

      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/send-order',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      print('SEND ORDER RESPONSE DATA: $responseData');
      if (responseData == null) return false;
      
      Map<String, dynamic> jsonMap;
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        return false;
      }

      final status = jsonMap['status'];
      if (status == 1 || status == '1' || status == true || status == 'success') {
        return true;
      }
      return false;
    } catch (e) {
      print('SEND ORDER ERROR: $e');
      return false;
    }
  }
}
