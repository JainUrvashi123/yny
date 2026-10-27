import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/theme_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/domain/usecases/update_password_usecase.dart';
import 'features/auth/domain/usecases/submit_contact_usecase.dart';
import 'features/auth/domain/usecases/delete_account_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';

import 'features/diamond/data/datasources/diamond_remote_datasource.dart';
import 'features/diamond/data/repositories/diamond_repository.dart';
import 'features/diamond/presentation/bloc/diamond_bloc.dart';

import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/data/repositories/cart_repository.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

import 'features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'features/wishlist/presentation/bloc/wishlist_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate Clean Architecture Layers
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  
  final loginUseCase = LoginUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final getProfileUseCase = GetProfileUseCase(authRepository);
  final updateProfileUseCase = UpdateProfileUseCase(authRepository);
  final updatePasswordUseCase = UpdatePasswordUseCase(authRepository);
  final submitContactUseCase = SubmitContactUseCase(authRepository);
  final deleteAccountUseCase = DeleteAccountUseCase(authRepository);

  final diamondRemoteDataSource = DiamondRemoteDataSourceImpl();
  final diamondRepository = DiamondRepositoryImpl(remoteDataSource: diamondRemoteDataSource);

  final cartRemoteDataSource = CartRemoteDataSourceImpl();
  final cartRepository = CartRepositoryImpl(remoteDataSource: cartRemoteDataSource);

  runApp(
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
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final SubmitContactUseCase submitContactUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final DiamondRepository diamondRepository;
  final CartRepository cartRepository;

  const MyApp({
    super.key,
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.forgotPasswordUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updatePasswordUseCase,
    required this.submitContactUseCase,
    required this.deleteAccountUseCase,
    required this.diamondRepository,
    required this.cartRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: loginUseCase,
            signUpUseCase: signUpUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            getProfileUseCase: getProfileUseCase,
            updateProfileUseCase: updateProfileUseCase,
            updatePasswordUseCase: updatePasswordUseCase,
            submitContactUseCase: submitContactUseCase,
            deleteAccountUseCase: deleteAccountUseCase,
          ),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(),
        ),
        BlocProvider<DiamondBloc>(
          create: (_) => DiamondBloc(repository: diamondRepository),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(repository: cartRepository),
        ),
        BlocProvider<WishlistCubit>(
          create: (_) => WishlistCubit(WishlistRemoteDataSourceImpl())..fetchWishlist(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
