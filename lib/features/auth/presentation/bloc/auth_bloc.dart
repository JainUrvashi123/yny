import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/submit_contact_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final SubmitContactUseCase submitContactUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.forgotPasswordUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updatePasswordUseCase,
    required this.submitContactUseCase,
    required this.deleteAccountUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthGetProfileRequested>(_onGetProfileRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthUpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<AuthContactSubmitRequested>(_onContactSubmitRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await loginUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
        ),
      );
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signUpUseCase(
        SignUpParams(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          password: event.password,
          company: event.company,
          address: event.address,
          unit: event.unit,
          city: event.city,
          countries: event.countries,
          state: event.state,
          zipcode: event.zipcode,
          phone: event.phone,
          website: event.website,
        ),
      );
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthForgotPasswordLoading());
    try {
      final message = await forgotPasswordUseCase(
        ForgotPasswordParams(email: event.email),
      );
      emit(AuthForgotPasswordSuccess(message: message));
    } catch (e) {
      emit(AuthForgotPasswordFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetProfileRequested(
    AuthGetProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthProfileLoadInProgress());
    try {
      final profile = await getProfileUseCase(
        GetProfileParams(userId: event.userId),
      );
      emit(AuthProfileLoadSuccess(profile: profile));
    } catch (e) {
      emit(AuthProfileLoadFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthProfileUpdateInProgress());
    try {
      final message = await updateProfileUseCase(
        UpdateProfileParams(
          userId: event.userId,
          firstName: event.firstName,
          lastName: event.lastName,
          mobile: event.mobile,
        ),
      );
      emit(AuthProfileUpdateSuccess(message: message));
    } catch (e) {
      emit(AuthProfileUpdateFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdatePasswordRequested(
    AuthUpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthPasswordUpdateInProgress());
    try {
      final message = await updatePasswordUseCase(
        UpdatePasswordParams(
          userId: event.userId,
          oldPassword: event.oldPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        ),
      );
      emit(AuthPasswordUpdateSuccess(message: message));
    } catch (e) {
      emit(AuthPasswordUpdateFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onContactSubmitRequested(
    AuthContactSubmitRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthContactSubmitInProgress());
    try {
      final message = await submitContactUseCase(
        SubmitContactParams(
          fullName: event.fullName,
          email: event.email,
          mobile: event.mobile,
          message: event.message,
        ),
      );
      emit(AuthContactSubmitSuccess(message: message));
    } catch (e) {
      emit(AuthContactSubmitFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthDeleteAccountInProgress());
    try {
      final message = await deleteAccountUseCase(
        DeleteAccountParams(userId: event.userId),
      );
      emit(AuthDeleteAccountSuccess(message: message));
    } catch (e) {
      emit(AuthDeleteAccountFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
