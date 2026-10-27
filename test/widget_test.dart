import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yny/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yny/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yny/features/diamond/data/datasources/diamond_remote_datasource.dart';
import 'package:yny/features/diamond/data/repositories/diamond_repository.dart';
import 'package:yny/features/auth/domain/usecases/login_usecase.dart';
import 'package:yny/features/auth/domain/usecases/signup_usecase.dart';
import 'package:yny/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:yny/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:yny/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:yny/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:yny/features/auth/domain/usecases/submit_contact_usecase.dart';
import 'package:yny/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:yny/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:yny/features/cart/data/repositories/cart_repository.dart';
import 'package:yny/main.dart';

void main() {
  testWidgets('YNY Auth Flow Render Smoke Test', (WidgetTester tester) async {
    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Instantiate test environment services
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    final loginUseCase = LoginUseCase(repository);
    final signUpUseCase = SignUpUseCase(repository);
    final forgotPasswordUseCase = ForgotPasswordUseCase(repository);
    final getProfileUseCase = GetProfileUseCase(repository);
    final updateProfileUseCase = UpdateProfileUseCase(repository);
    final updatePasswordUseCase = UpdatePasswordUseCase(repository);
    final submitContactUseCase = SubmitContactUseCase(repository);
    final deleteAccountUseCase = DeleteAccountUseCase(repository);

    final diamondRemoteDataSource = DiamondRemoteDataSourceImpl();
    final diamondRepository = DiamondRepositoryImpl(remoteDataSource: diamondRemoteDataSource);

    final cartRemoteDataSource = CartRemoteDataSourceImpl();
    final cartRepository = CartRepositoryImpl(remoteDataSource: cartRemoteDataSource);

    // Build the app
    await tester.pumpWidget(
      MyApp(
        loginUseCase: loginUseCase,
        signUpUseCase: signUpUseCase,
        forgotPasswordUseCase: forgotPasswordUseCase,
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
        updatePasswordUseCase: updatePasswordUseCase,
        submitContactUseCase: submitContactUseCase,
        deleteAccountUseCase: deleteAccountUseCase,
        diamondRepository: diamondRepository,
        cartRepository: cartRepository,
      ),
    );

    // Wait for the fonts or initialization to complete
    await tester.pumpAndSettle();

    // Verify that the YNY logo and Login interface elements are displayed
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}
