import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> signup({
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
