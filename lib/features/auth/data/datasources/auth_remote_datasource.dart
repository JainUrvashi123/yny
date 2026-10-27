import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String company,
    required String address,
    required String unit,
    required String city,
    required String countries,
    required String state,
    required String zipcode,
    required String phone,
    required String website,
  });

  Future<String> forgotPassword({required String email});

  Future<Map<String, dynamic>> getProfile({required String userId});

  Future<String> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String mobile,
  });

  Future<String> updatePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<String> submitContactForm({
    required String fullName,
    required String email,
    required String mobile,
    required String message,
  });

  Future<String> deleteAccount({required String userId});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/login',
        data: {
          'username': email.trim(),
          'password': password,
        },
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
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Invalid email or password.';
        throw Exception(message);
      }

      final dataMap = jsonMap['data'] is Map ? jsonMap['data'] as Map<String, dynamic> : <String, dynamic>{};
      final name = dataMap['name']?.toString() ?? dataMap['username']?.toString() ?? email.split('@').first;
      final userId = dataMap['id']?.toString() ?? dataMap['user_id']?.toString() ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      final userEmail = dataMap['email']?.toString() ?? dataMap['username']?.toString() ?? email;

      return UserModel(
        id: userId,
        email: userEmail,
        name: name,
      );
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
  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String company,
    required String address,
    required String unit,
    required String city,
    required String countries,
    required String state,
    required String zipcode,
    required String phone,
    required String website,
  }) async {
    try {
      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/signup',
        data: {
          'email': email.trim(),
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'password': password,
          'company': company.trim(),
          'address': address.trim(),
          'unit': unit.trim(),
          'city': city.trim(),
          'countries': countries.trim(),
          'state': state.trim(),
          'zipcode': zipcode.trim(),
          'phone': phone.trim(),
          'website': website.trim(),
        },
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (responseData == null) {
        throw Exception('Server returned an empty response.');
      }

      Map<String, dynamic> jsonMap;
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Please fill the form correctly.';
        throw Exception(message);
      }

      final dataMap = jsonMap['data'] is Map ? jsonMap['data'] as Map<String, dynamic> : <String, dynamic>{};
      final name = '${firstName.trim()} ${lastName.trim()}';
      final userId = dataMap['id']?.toString() ?? dataMap['user_id']?.toString() ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      final userEmail = dataMap['email']?.toString() ?? dataMap['username']?.toString() ?? email;

      return UserModel(
        id: userId,
        email: userEmail,
        name: name,
      );
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
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/forgot-password',
        data: {'email': email.trim()},
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
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Unable to send password reset email.';
        throw Exception(message);
      }

      return jsonMap['message']?.toString() ?? 'Please check your email for password reset.';
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
  Future<Map<String, dynamic>> getProfile({required String userId}) async {
    try {
      final response = await _dio.get(
        'https://ynyjewelsinc.com/m_api/get-profile',
        data: {'userId': userId},
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
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Unable to fetch profile.';
        throw Exception(message);
      }

      final dataMap = jsonMap['data'] is Map ? jsonMap['data'] as Map<String, dynamic> : <String, dynamic>{};
      return dataMap;
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
  Future<String> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String mobile,
  }) async {
    try {
      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/profile-update',
        data: {
          'userId': int.tryParse(userId) ?? userId,
          'firstname': firstName.trim(),
          'lastname': lastName.trim(),
          'mobile': mobile.trim(),
        },
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
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Unable to update profile.';
        throw Exception(message);
      }

      return jsonMap['message']?.toString() ?? 'Profile updated successfully.';
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
  Future<String> updatePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/password-update',
        data: {
          'user_id': int.tryParse(userId) ?? userId,
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
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
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Unable to update password.';
        throw Exception(message);
      }

      return jsonMap['message']?.toString() ?? 'Password updated successfully.';
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
  Future<String> submitContactForm({
    required String fullName,
    required String email,
    required String mobile,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/contact-submit',
        data: {
          'fullname': fullName.trim(),
          'email': email.trim(),
          'mobile': mobile.trim(),
          'massage': message.trim(), // API parameter is misspelled as 'massage'
        },
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
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final errMessage = jsonMap['message'] ?? 'Unable to submit contact form.';
        throw Exception(errMessage);
      }

      return jsonMap['message']?.toString() ?? 'Contact form submitted successfully.';
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
  Future<String> deleteAccount({required String userId}) async {
    try {
      final response = await _dio.post(
        'https://ynyjewelsinc.com/m_api/delete-account',
        data: {
          'user_id': userId,
        },
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
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      final status = jsonMap['status'];
      final isSuccess = status == 1 || status == '1' || status == true || status == 'success';

      if (!isSuccess) {
        final message = jsonMap['message'] ?? 'Unable to delete account.';
        throw Exception(message);
      }

      return jsonMap['message']?.toString() ?? 'Account deleted successfully.';
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
}
