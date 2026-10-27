import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<User> call(SignUpParams params) async {
    return await repository.signup(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
      company: params.company,
      address: params.address,
      unit: params.unit,
      city: params.city,
      countries: params.countries,
      state: params.state,
      zipcode: params.zipcode,
      phone: params.phone,
      website: params.website,
    );
  }
}

class SignUpParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String company;
  final String address;
  final String unit;
  final String city;
  final String countries;
  final String state;
  final String zipcode;
  final String phone;
  final String website;

  const SignUpParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.company,
    required this.address,
    required this.unit,
    required this.city,
    required this.countries,
    required this.state,
    required this.zipcode,
    required this.phone,
    required this.website,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        password,
        company,
        address,
        unit,
        city,
        countries,
        state,
        zipcode,
        phone,
        website,
      ];
}
