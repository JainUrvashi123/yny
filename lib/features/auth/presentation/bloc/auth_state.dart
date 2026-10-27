import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthForgotPasswordLoading extends AuthState {
  const AuthForgotPasswordLoading();
}

class AuthForgotPasswordSuccess extends AuthState {
  final String message;

  const AuthForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthForgotPasswordFailure extends AuthState {
  final String errorMessage;

  const AuthForgotPasswordFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthProfileLoadInProgress extends AuthState {
  const AuthProfileLoadInProgress();
}

class AuthProfileLoadSuccess extends AuthState {
  final Map<String, dynamic> profile;

  const AuthProfileLoadSuccess({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class AuthProfileLoadFailure extends AuthState {
  final String errorMessage;

  const AuthProfileLoadFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthProfileUpdateInProgress extends AuthState {
  const AuthProfileUpdateInProgress();
}

class AuthProfileUpdateSuccess extends AuthState {
  final String message;

  const AuthProfileUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthProfileUpdateFailure extends AuthState {
  final String errorMessage;

  const AuthProfileUpdateFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthPasswordUpdateInProgress extends AuthState {
  const AuthPasswordUpdateInProgress();
}

class AuthPasswordUpdateSuccess extends AuthState {
  final String message;

  const AuthPasswordUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthPasswordUpdateFailure extends AuthState {
  final String errorMessage;

  const AuthPasswordUpdateFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthContactSubmitInProgress extends AuthState {
  const AuthContactSubmitInProgress();
}

class AuthContactSubmitSuccess extends AuthState {
  final String message;

  const AuthContactSubmitSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthContactSubmitFailure extends AuthState {
  final String errorMessage;

  const AuthContactSubmitFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthDeleteAccountInProgress extends AuthState {
  const AuthDeleteAccountInProgress();
}

class AuthDeleteAccountSuccess extends AuthState {
  final String message;

  const AuthDeleteAccountSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthDeleteAccountFailure extends AuthState {
  final String errorMessage;

  const AuthDeleteAccountFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
