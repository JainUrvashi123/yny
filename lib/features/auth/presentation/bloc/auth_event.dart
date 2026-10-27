import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
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

  const AuthSignUpRequested({
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

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthGetProfileRequested extends AuthEvent {
  final String userId;

  const AuthGetProfileRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String userId;
  final String firstName;
  final String lastName;
  final String mobile;

  const AuthUpdateProfileRequested({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, mobile];
}

class AuthUpdatePasswordRequested extends AuthEvent {
  final String userId;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const AuthUpdatePasswordRequested({
    required this.userId,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [userId, oldPassword, newPassword, confirmPassword];
}

class AuthContactSubmitRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String mobile;
  final String message;

  const AuthContactSubmitRequested({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.message,
  });

  @override
  List<Object?> get props => [fullName, email, mobile, message];
}

class AuthDeleteAccountRequested extends AuthEvent {
  final String userId;

  const AuthDeleteAccountRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
