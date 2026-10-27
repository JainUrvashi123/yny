import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diamond_model.dart';

abstract class DiamondRemoteDataSource {
  Future<bool> addToCart({
    required String stock,
    int qty = 1,
  });

  Future<DiamondResponseModel> getDiamondList({

    int page = 0,
    int perPage = 50,
    String stock = "",
    List<String>? shapes,
    List<String>? colors,
    List<String>? fancyColors,
    List<String>? clarities,
    List<String>? cuts,
    List<String>? polishes,
    List<String>? symmetries,
    List<String>? labs,
    List<String>? fluorescences,
    List<String>? makes,
    List<String>? culets,
    List<String>? available,
    String? caratFrom,
    String? caratTo,
    String? priceFrom,
    String? priceTo,
    String? ratioFrom,
    String? ratioTo,
    String? depthFrom,
    String? depthTo,
    String? tableFrom,
    String? tableTo,
    String? crAngleFrom,
    String? crAngleTo,
    String? crHeightFrom,
    String? crHeightTo,
    String? pavAngleFrom,
    String? pavAngleTo,
    String? pavHeightFrom,
    String? pavHeightTo,
    String? girdleFrom,
    String? girdleTo,
    String? starLengthFrom,
    String? starLengthTo,
    String? lengthFrom,
    String? lengthTo,
    String? widthFrom,
    String? widthTo,
  });
}

class DiamondRemoteDataSourceImpl implements DiamondRemoteDataSource {
  final Dio _dio;

  DiamondRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<DiamondResponseModel> getDiamondList({

    int page = 0,
    int perPage = 50,
    String stock = "",
    List<String>? shapes,
    List<String>? colors,
    List<String>? fancyColors,
    List<String>? clarities,
    List<String>? cuts,
    List<String>? polishes,
    List<String>? symmetries,
    List<String>? labs,

    List<String>? fluorescences,
    List<String>? makes,
    List<String>? culets,
    List<String>? available,
    String? caratFrom,
    String? caratTo,
    String? priceFrom,
    String? priceTo,
    String? ratioFrom,
    String? ratioTo,
    String? depthFrom,
    String? depthTo,
    String? tableFrom,
    String? tableTo,
    String? crAngleFrom,
    String? crAngleTo,
    String? crHeightFrom,
    String? crHeightTo,
    String? pavAngleFrom,
    String? pavAngleTo,
    String? pavHeightFrom,
    String? pavHeightTo,
    String? girdleFrom,
    String? girdleTo,
    String? starLengthFrom,
    String? starLengthTo,
    String? lengthFrom,
    String? lengthTo,
    String? widthFrom,
    String? widthTo,
  }) async {

    try {
      final data = <String, dynamic>{
        "page": page,
        "per_page": perPage,
        if (stock.isNotEmpty) "stock": stock,
      };

      void addIfNotEmpty(String key, List<String>? list) {
        if (list != null && list.isNotEmpty) {
          data[key] = list;
        }
      }

      void addStringIfNotEmpty(String key, String? val) {
        if (val != null && val.isNotEmpty) {
          data[key] = val;
        }
      }

      addIfNotEmpty("shape", shapes);
      addIfNotEmpty("color", colors);
      addIfNotEmpty("fancy_color", fancyColors);
      addIfNotEmpty("clarity", clarities);
      addIfNotEmpty("cut", cuts);
      addIfNotEmpty("polish", polishes);
      addIfNotEmpty("symmetry", symmetries);
      addIfNotEmpty("cert", labs);
      addIfNotEmpty("fluorescence", fluorescences);
      addIfNotEmpty("make", makes);
      addIfNotEmpty("culet", culets);
      addIfNotEmpty("available", available);

      addStringIfNotEmpty("carat_from", caratFrom);
      addStringIfNotEmpty("carat_to", caratTo);
      addStringIfNotEmpty("price_from", priceFrom);
      addStringIfNotEmpty("price_to", priceTo);
      addStringIfNotEmpty("ratio_from", ratioFrom);
      addStringIfNotEmpty("ratio_to", ratioTo);
      addStringIfNotEmpty("depth_per_from", depthFrom);
      addStringIfNotEmpty("depth_per_to", depthTo);
      addStringIfNotEmpty("table_per_from", tableFrom);
      addStringIfNotEmpty("table_per_to", tableTo);
      addStringIfNotEmpty("cr_angle_from", crAngleFrom);
      addStringIfNotEmpty("cr_angle_to", crAngleTo);
      addStringIfNotEmpty("cr_height_from", crHeightFrom);
      addStringIfNotEmpty("cr_height_to", crHeightTo);
      addStringIfNotEmpty("pav_angle_from", pavAngleFrom);
      addStringIfNotEmpty("pav_angle_to", pavAngleTo);
      addStringIfNotEmpty("pav_height_from", pavHeightFrom);
      addStringIfNotEmpty("pav_height_to", pavHeightTo);
      addStringIfNotEmpty("girdle_per_from", girdleFrom);
      addStringIfNotEmpty("girdle_per_to", girdleTo);
      addStringIfNotEmpty("star_len_from", starLengthFrom);
      addStringIfNotEmpty("star_len_to", starLengthTo);
      addStringIfNotEmpty("length_from", lengthFrom);
      addStringIfNotEmpty("length_to", lengthTo);
      addStringIfNotEmpty("width_from", widthFrom);
      addStringIfNotEmpty("width_to", widthTo);
      addStringIfNotEmpty("m_length_from", lengthFrom);
      addStringIfNotEmpty("m_length_to", lengthTo);
      addStringIfNotEmpty("m_width_from", widthFrom);
      addStringIfNotEmpty("m_width_to", widthTo);

      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/diamond-list',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (responseData == null) {
        throw Exception('Server returned an empty response.');
      }

      Map<String, dynamic> jsonMap;
      if (responseData is Map) {
        jsonMap = Map<String, dynamic>.from(responseData);
      } else if (responseData is String) {
        final decoded = json.decode(responseData);
        if (decoded is Map) {
          jsonMap = Map<String, dynamic>.from(decoded);
        } else {
          throw Exception('Unexpected server response format.');
        }
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Unable to fetch diamond list.';
        throw Exception(message);
      }

      return DiamondResponseModel.fromJson(jsonMap);
    } on DioException catch (dioError) {
      String errorMessage = 'A network error occurred. Please try again.';
      if (dioError.response != null && dioError.response?.data != null) {
        final resData = dioError.response?.data;
        if (resData is Map && resData.containsKey('message')) {
          errorMessage = resData['message'].toString();
        } else if (resData is Map && resData.containsKey('error')) {
          errorMessage = resData['error'].toString();
        }
      } else if (dioError.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> addToCart({
    required String stock,
    int qty = 1,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('user_id') ?? '0';
      final userId = int.tryParse(userIdStr) ?? 0;

      final data = <String, dynamic>{
        "user_id": userId,
        "stock_id": stock,
        "qty": qty,
      };

      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/diamond/add-cart',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (responseData == null) return false;
      
      Map<String, dynamic> jsonMap;
      if (responseData is Map) {
        jsonMap = Map<String, dynamic>.from(responseData);
      } else if (responseData is String) {
        final decoded = json.decode(responseData);
        if (decoded is Map) {
          jsonMap = Map<String, dynamic>.from(decoded);
        } else {
          return false;
        }
      } else {
        return false;
      }

      final status = jsonMap['status'];
      return status == 1 || status == '1' || status == true || status == 'success';
    } catch (e) {
      return false;
    }
  }
}



