import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.login(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      return await remoteDataSource.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        company: company,
        address: address,
        unit: unit,
        city: city,
        countries: countries,
        state: state,
        zipcode: zipcode,
        phone: phone,
        website: website,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    try {
      return await remoteDataSource.forgotPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile({required String userId}) async {
    try {
      return await remoteDataSource.getProfile(userId: userId);
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
      return await remoteDataSource.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
      );
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
      return await remoteDataSource.updatePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
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
      return await remoteDataSource.submitContactForm(
        fullName: fullName,
        email: email,
        mobile: mobile,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> deleteAccount({required String userId}) async {
    try {
      return await remoteDataSource.deleteAccount(userId: userId);
    } catch (e) {
      rethrow;
    }
  }
}
