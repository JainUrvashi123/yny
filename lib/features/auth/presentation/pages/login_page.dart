import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/constants.dart';
import 'package:yny/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:yny/core/bloc/theme_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remember_email');
    final savedPassword = prefs.getString('remember_password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('remember_email', _emailController.text);
        await prefs.setString('remember_password', _passwordController.text);
      } else {
        await prefs.remove('remember_email');
        await prefs.remove('remember_password');
      }

      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  void _onForgotPasswordPressed() {
    final emailDialogController = TextEditingController(text: _emailController.text);
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthForgotPasswordSuccess) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppConstants.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else if (state is AuthForgotPasswordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppConstants.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthForgotPasswordLoading;
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppConstants.surfaceColor
                  : AppConstants.lightSurfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppConstants.borderLight
                      : AppConstants.lightBorderLight,
                ),
              ),
              title: Text(
                'Forgot Password',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter your email address and we will send you a link to reset your password.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    CustomTextField(
                      controller: emailDialogController,
                      labelText: 'Email Address',
                      hintText: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!val.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppConstants.textSecondary
                        : AppConstants.lightTextSecondary,
                  ),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (dialogFormKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthForgotPasswordRequested(
                                    email: emailDialogController.text.trim(),
                                  ),
                                );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppConstants.accentColorDark
                        : AppConstants.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'SEND LINK',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceMD, top: 8),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () {
                context.read<ThemeBloc>().add(const ThemeToggleRequested());
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
                side: BorderSide(
                  color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Save user session in shared preferences
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('user_id', state.user.id);
              prefs.setString('user_name', state.user.name);
              prefs.setString('user_email', state.user.email);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${state.user.name}!'),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // Navigate to dynamic premium DashboardPage
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => DashboardPage(
                  userId: state.user.id,
                  userName: state.user.name,
                  userEmail: state.user.email,
                ),
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Beautiful Atmospheric Ambient Glow Blobs in Background
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark ? AppConstants.accentColorDark : AppConstants.accentColor).withOpacity(0.12),
                    border: Border.all(color: (isDark ? AppConstants.accentColorDark : AppConstants.accentColor).withOpacity(0.05), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.accentSecondary.withOpacity(0.08),
                  ),
                ),
              ),


              // Core Login Panel
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 2),
                            
                            // App Logo Header
                            Center(
                              child: Container(
                                height: 90,
                                width: 90,
                                padding: const EdgeInsets.all(AppConstants.spaceXS),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppConstants.surfaceColor
                                      : AppConstants.lightSurfaceColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppConstants.borderLight
                                        : AppConstants.lightBorderLight,
                                  ),
                                  boxShadow: AppConstants.glassShadow,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.asset(
                                    'assets/images/yny-logo.png',
                                    fit: BoxFit.contain,
                                    color: isDark ? Colors.white : null,
                                    colorBlendMode: isDark ? BlendMode.srcIn : null,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: AppConstants.spaceXL),
                            
                            // Greeting
                            Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.spaceSM),
                            Text(
                              'Welcome back. Enter your credentials to access your portal.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            
                            const Spacer(flex: 1),
                            
                            // Inputs Card
                            Container(
                              padding: const EdgeInsets.all(AppConstants.spaceLG),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppConstants.surfaceColor
                                    : AppConstants.lightSurfaceColor,
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppConstants.borderLight
                                      : AppConstants.lightBorderLight,
                                ),
                                boxShadow: AppConstants.glassShadow,
                              ),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _emailController,
                                    labelText: 'Email Address',
                                    hintText: 'name@example.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!val.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppConstants.spaceMD + 4),
                                  CustomTextField(
                                    controller: _passwordController,
                                    labelText: 'Password',
                                    hintText: '••••••••',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Remember Me checkbox
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (val) {
                                                setState(() {
                                                  _rememberMe = val ?? false;
                                                });
                                              },
                                              activeColor: Theme.of(context).colorScheme.secondary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              side: BorderSide(
                                                color: isDark 
                                                    ? AppConstants.textMuted 
                                                    : AppConstants.lightBorderLight,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Remember Me',
                                            style: GoogleFonts.nunito(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isDark 
                                                  ? AppConstants.textSecondary 
                                                  : AppConstants.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Forgot Password text button
                                      TextButton(
                                        onPressed: _onForgotPasswordPressed,
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppConstants.accentSecondary,
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Forgot Password?',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            

                            
                            const SizedBox(height: AppConstants.spaceLG),
                            
                            // Submit Action
                            AuthButton(
                              text: 'SIGN IN',
                              isLoading: state is AuthLoading,
                              onTap: _onLoginPressed,
                            ),
                            
                            const SizedBox(height: AppConstants.spaceMD),
                            
                            // Continue as Guest Action
                            GestureDetector(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('user_id', 'guest');
                                await prefs.setString('user_name', 'Guest User');
                                await prefs.setString('user_email', 'guest@yny.com');
                                if (mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const DashboardPage(
                                        userId: 'guest',
                                        userName: 'Guest User',
                                        userEmail: 'guest@yny.com',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: isDark 
                                        ? AppConstants.accentColorDark.withOpacity(0.5) 
                                        : AppConstants.accentColor.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'CONTINUE AS GUEST',
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark 
                                        ? AppConstants.accentColorDark 
                                        : AppConstants.accentColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            
                            const Spacer(flex: 2),
                            
                            // Register Navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpPage(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.secondary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      shadows: AppConstants.textGlow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spaceLG),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessDialog(String name, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppConstants.surfaceColor
            : AppConstants.lightSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppConstants.borderLight
                : AppConstants.lightBorderLight,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppConstants.successColor, size: 28),
            const SizedBox(width: 12),
            Text(
              'Auth Successful',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully authenticated user details:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Name: $name',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Email: $email',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
            child: Text(
              'LOGOUT',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
