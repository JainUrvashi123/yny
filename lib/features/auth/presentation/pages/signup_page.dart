import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/constants.dart';
import 'package:yny/core/bloc/theme_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import 'terms_and_conditions_page.dart';
import 'login_page.dart';
import 'package:flutter/gestures.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipcodeController = TextEditingController();

  String _selectedCountry = 'United States';
  String _selectedCountryCode = '+1'; // Fully working interactive country code value
  bool _termsAccepted = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please accept the terms and conditions.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      final fullName = _fullNameController.text.trim();
      final parts = fullName.split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      // Prepare unified phone number including country code
      final rawCode = _selectedCountryCode.split(' ').first;
      final fullPhoneNumber = '$rawCode${_phoneController.text.trim()}';

      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              firstName: firstName,
              lastName: lastName,
              email: _emailController.text.trim(),
              password: _passwordController.text,
              company: _companyController.text.trim(),
              address: _addressController.text.trim(),
              unit: 'A-101', // Standard fallback unit for API
              city: _cityController.text.trim(),
              countries: _selectedCountry,
              state: _stateController.text.trim(),
              zipcode: _zipcodeController.text.trim(),
              phone: fullPhoneNumber,
              website: 'https://ynyjewelsinc.com', // Standard fallback website
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use mockup soft gray-blue background in light mode
    final scaffoldBgColor = isDark 
        ? AppConstants.backgroundColor 
        : const Color(0xFFE1E6EB);

    final brandPrimaryColor = isDark 
        ? Colors.white 
        : const Color(0xFF0F3F70);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.spaceMD, top: 8),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F3F70),
              size: 20,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppConstants.surfaceColor
                  : Colors.white,
              side: BorderSide(
                color: isDark
                    ? AppConstants.borderLight
                    : AppConstants.lightBorderLight,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceMD, top: 8),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.white : const Color(0xFF0F3F70),
                size: 20,
              ),
              onPressed: () {
                context.read<ThemeBloc>().add(const ThemeToggleRequested());
              },
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppConstants.surfaceColor
                    : Colors.white,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account successfully created for ${state.user.name}! Please login.',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // Return back to the login page
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
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
              // Beautiful Atmospheric Ambient Glow Blobs in Background (Light/Dark optimized)
              Positioned(
                top: -120,
                left: -120,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark ? AppConstants.accentColorDark : AppConstants.accentColor).withOpacity(isDark ? 0.12 : 0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.accentSecondary.withOpacity(isDark ? 0.08 : 0.03),
                  ),
                ),
              ),

              // Core Sign Up Panel
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // Mockup Branding Header
                        Text(
                          'YNY',
                          style: GoogleFonts.outfit(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: brandPrimaryColor,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CREATE ACCOUNT',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: brandPrimaryColor.withOpacity(0.85),
                            letterSpacing: 4.0,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // 1. Full Name Input Box (Takes its own line)
                        _buildField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            final trimmed = val.trim();
                            if (!trimmed.contains(' ') || trimmed.split(' ').where((s) => s.isNotEmpty).length < 2) {
                              return 'Please enter both your first and last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 2. Email Input Box (Takes its own line)
                        _buildField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(val.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 3. Fully Working Interactive Country Code Selection Dropdown (Takes its own line)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppConstants.surfaceColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(color: AppConstants.borderLight, width: 1.2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountryCode,
                              dropdownColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(
                                    Icons.phone_rounded,
                                    color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                    size: 18,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                                  size: 18,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: '+1',
                                  child: Text(
                                    '🇺🇸 United States (+1)',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '+91',
                                  child: Text(
                                    '🇮🇳 India (+91)',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '+44',
                                  child: Text(
                                    '🇬🇧 United Kingdom (+44)',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '+61',
                                  child: Text(
                                    '🇦🇺 Australia (+61)',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (String? newVal) {
                                if (newVal != null) {
                                  setState(() {
                                    _selectedCountryCode = newVal;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 4. Phone Number Input Field (Takes its own line)
                        _buildField(
                          controller: _phoneController,
                          hintText: 'Phone Number',
                          prefixIcon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter phone number';
                            }
                            final cleanPhone = val.replaceAll(RegExp(r'\D'), '');
                            if (cleanPhone.length < 7 || cleanPhone.length > 15) {
                              return 'Please enter a valid phone number (7-15 digits)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 5. Password Input Field (Takes its own line)
                        _buildField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _passwordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter password';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 6. Confirm Password Input Field (Takes its own line)
                        _buildField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _confirmPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please confirm password';
                            if (val != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 7. Company Name Input (Takes its own line)
                        _buildField(
                          controller: _companyController,
                          hintText: 'Company Name',
                          prefixIcon: Icons.business_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 8. Company Address Input (Takes its own line)
                        _buildField(
                          controller: _addressController,
                          hintText: 'Company Address',
                          prefixIcon: Icons.location_on_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter company address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 9. Country Selection Dropdown (Takes its own line)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppConstants.surfaceColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(color: AppConstants.borderLight, width: 1.2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              dropdownColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(
                                    Icons.public_rounded,
                                    color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                    size: 18,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                                  size: 18,
                                ),
                              ),
                              items: ['United States', 'India', 'Canada', 'United Kingdom'].map((String val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(
                                    val,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newVal) {
                                if (newVal != null) {
                                  setState(() {
                                    _selectedCountry = newVal;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 10. State Input Field (Takes its own line)
                        _buildField(
                          controller: _stateController,
                          hintText: 'State',
                          prefixIcon: Icons.map_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter state';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 11. City Input Field (Takes its own line)
                        _buildField(
                          controller: _cityController,
                          hintText: 'City',
                          prefixIcon: Icons.location_city_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter city';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 12. Zipcode Input Field (Takes its own line)
                        _buildField(
                          controller: _zipcodeController,
                          hintText: 'Zipcode',
                          prefixIcon: Icons.pin_drop_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter zipcode';
                            final cleanZip = val.trim().replaceAll(RegExp(r'\s+'), '');
                            if (cleanZip.length < 3 || cleanZip.length > 10) {
                              return 'Please enter a valid zipcode (3-10 characters)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // 13. Accept Terms Checkbox row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _termsAccepted,
                                activeColor: isDark ? AppConstants.accentColorDark : const Color(0xFF0F3F70),
                                onChanged: (bool? val) {
                                  setState(() {
                                    _termsAccepted = val ?? false;
                                  });
                                },
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
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I have read and accept ',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : const Color(0xFF0F3F70),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'terms and condition.',
                                      style: GoogleFonts.nunito(
                                        color: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const TermsAndConditionsPage(),
                                              fullscreenDialog: true,
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 14. Centered Solid primary AuthButton
                        AuthButton(
                          text: 'SIGN UP',
                          isLoading: state is AuthLoading,
                          onTap: _onSignUpPressed,
                        ),

                        const SizedBox(height: 24),

                        // Back to Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const LoginPage()),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? AppConstants.accentColorDark : const Color(0xFF0F3F70),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppConstants.borderLight, width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
            size: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                    size: 18,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
