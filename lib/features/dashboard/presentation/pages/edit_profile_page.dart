import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../../core/services/version_check_service.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final int initialTab;

  const EditProfilePage({
    super.key,
    required this.userId,
    this.initialTab = 0,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Profile Info controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Password controllers
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    // Trigger profile fetch immediately on load
    context.read<AuthBloc>().add(AuthGetProfileRequested(userId: widget.userId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUpdateProfilePressed() {
    if (_profileFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthUpdateProfileRequested(
              userId: widget.userId,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              mobile: _phoneController.text.trim(),
            ),
          );
    }
  }

  void _onChangePasswordPressed() {
    if (_passwordFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthUpdatePasswordRequested(
              userId: widget.userId,
              oldPassword: _oldPasswordController.text,
              newPassword: _newPasswordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
              side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'My Profile',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
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
                backgroundColor: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthProfileLoadSuccess) {
            final profile = state.profile;
            _firstNameController.text = profile['firstname']?.toString() ?? '';
            _lastNameController.text = profile['lastname']?.toString() ?? '';
            _phoneController.text = profile['phone']?.toString() ?? profile['mobile']?.toString() ?? '';
            _emailController.text = profile['email']?.toString() ?? '';
          } else if (state is AuthProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // Refresh local profile state
            context.read<AuthBloc>().add(AuthGetProfileRequested(userId: widget.userId));
          } else if (state is AuthPasswordUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // Clear passwords fields
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          } else if (state is AuthProfileLoadFailure) {
            if (state.errorMessage.contains('User not found') || state.errorMessage.contains('not found')) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading profile: ${state.errorMessage}'),
                  backgroundColor: AppConstants.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          } else if (state is AuthProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating profile: ${state.errorMessage}'),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is AuthPasswordUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating password: ${state.errorMessage}'),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is AuthDeleteAccountSuccess) {
            // Wipe SharedPreferences
            SharedPreferences.getInstance().then((prefs) => prefs.clear());
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            
            // Navigate back to login page
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          } else if (state is AuthDeleteAccountFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting account: ${state.errorMessage}'),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isProfileLoading = state is AuthProfileLoadInProgress;
          final isProfileUpdating = state is AuthProfileUpdateInProgress;
          final isPasswordUpdating = state is AuthPasswordUpdateInProgress;

          return Stack(
            children: [
              // atmospheric glow backgrounds
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.accentSecondary.withOpacity(0.04),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    _buildUpdateBanner(context),
                    const SizedBox(height: AppConstants.spaceMD),
                    
                    // Premium Glassmorphic Tab Selector
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                        ),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: -2,
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  spreadRadius: -1,
                                )
                              ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        indicator: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                        labelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_outline_rounded, size: 16),
                                  SizedBox(width: 6),
                                  Text('Profile Details'),
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline_rounded, size: 16),
                                  SizedBox(width: 6),
                                  Text('Change Password'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceLG),

                    // Active view switching
                    Expanded(
                      child: isProfileLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: Profile Info Form
                                SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                                  child: Form(
                                    key: _profileFormKey,
                                    child: Column(
                                      children: [
                                        // Dynamic Avatar Card
                                        Center(
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 90,
                                                height: 90,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [accentColor, AppConstants.accentSecondary],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: accentColor.withOpacity(0.2),
                                                      blurRadius: 16,
                                                      offset: const Offset(0, 8),
                                                    )
                                                  ],
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  _firstNameController.text.isNotEmpty
                                                      ? _firstNameController.text.substring(0, 1).toUpperCase()
                                                      : 'U',
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: const BoxDecoration(
                                                    color: AppConstants.successColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: AppConstants.spaceLG * 1.5),

                                        // Fields glass container
                                        Container(
                                          padding: const EdgeInsets.all(AppConstants.spaceLG),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(
                                              color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                                            ),
                                            boxShadow: AppConstants.glassShadow,
                                          ),
                                          child: Column(
                                            children: [
                                              CustomTextField(
                                                controller: _firstNameController,
                                                labelText: 'First Name',
                                                hintText: 'Enter first name',
                                                prefixIcon: Icons.person_outline_rounded,
                                                validator: (val) {
                                                  if (val == null || val.trim().isEmpty) {
                                                    return 'Please enter first name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: AppConstants.spaceMD),
                                              CustomTextField(
                                                controller: _lastNameController,
                                                labelText: 'Last Name',
                                                hintText: 'Enter last name',
                                                prefixIcon: Icons.person_outline_rounded,
                                                validator: (val) {
                                                  if (val == null || val.trim().isEmpty) {
                                                    return 'Please enter last name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: AppConstants.spaceMD),
                                              CustomTextField(
                                                controller: _phoneController,
                                                labelText: 'Phone Number',
                                                hintText: 'Enter phone number',
                                                prefixIcon: Icons.phone_outlined,
                                                keyboardType: TextInputType.phone,
                                                validator: (val) {
                                                  if (val == null || val.trim().isEmpty) {
                                                    return 'Please enter phone number';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: AppConstants.spaceMD),
                                              // Read Only Email Field
                                              CustomTextField(
                                                controller: _emailController,
                                                labelText: 'Email Address (Read-Only)',
                                                hintText: 'email@example.com',
                                                prefixIcon: Icons.email_outlined,
                                                enabled: false,
                                                validator: null,
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        const SizedBox(height: AppConstants.spaceXL),

                                        // Submit button
                                        ElevatedButton(
                                          onPressed: isProfileUpdating ? null : _onUpdateProfilePressed,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMD + 2),
                                            minimumSize: const Size(double.infinity, 50),
                                            elevation: 4,
                                          ),
                                          child: isProfileUpdating
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  'UPDATE PROFILE',
                                                  style: GoogleFonts.nunito(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),

                                        // Delete Account button
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(top: AppConstants.spaceLG),
                                          child: TextButton.icon(
                                            onPressed: () => _showDeleteAccountDialog(context),
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            label: Text(
                                              'DELETE MY ACCOUNT',
                                              style: GoogleFonts.nunito(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.redAccent,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                              ),
                                              backgroundColor: Colors.redAccent.withOpacity(0.05),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppConstants.spaceXL),
                                      ],
                                    ),
                                  ),
                                ),

                                // Tab 2: Change Password Form
                                SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                                  child: Form(
                                    key: _passwordFormKey,
                                    child: Column(
                                      children: [
                                        // Lock Security Icon Header
                                        Center(
                                          child: Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                                              border: Border.all(
                                                color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.shield_outlined,
                                              size: 40,
                                              color: accentColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppConstants.spaceLG * 1.5),

                                        // Password Glass Container
                                        Container(
                                          padding: const EdgeInsets.all(AppConstants.spaceLG),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(
                                              color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                                            ),
                                            boxShadow: AppConstants.glassShadow,
                                          ),
                                          child: Column(
                                            children: [
                                              CustomTextField(
                                                controller: _oldPasswordController,
                                                labelText: 'Current Password',
                                                hintText: '••••••••',
                                                prefixIcon: Icons.lock_outline_rounded,
                                                isPassword: true,
                                                validator: (val) {
                                                  if (val == null || val.isEmpty) {
                                                    return 'Please enter current password';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: AppConstants.spaceMD),
                                              CustomTextField(
                                                controller: _newPasswordController,
                                                labelText: 'New Password',
                                                hintText: '••••••••',
                                                prefixIcon: Icons.lock_outline_rounded,
                                                isPassword: true,
                                                validator: (val) {
                                                  if (val == null || val.isEmpty) {
                                                    return 'Please enter new password';
                                                  }
                                                  if (val.length < 6) {
                                                    return 'Password must be at least 6 characters';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: AppConstants.spaceMD),
                                              CustomTextField(
                                                controller: _confirmPasswordController,
                                                labelText: 'Confirm New Password',
                                                hintText: '••••••••',
                                                prefixIcon: Icons.lock_outline_rounded,
                                                isPassword: true,
                                                validator: (val) {
                                                  if (val == null || val.isEmpty) {
                                                    return 'Please confirm your new password';
                                                  }
                                                  if (val != _newPasswordController.text) {
                                                    return 'Passwords do not match';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: AppConstants.spaceXL),

                                        // Submit password button
                                        ElevatedButton(
                                          onPressed: isPasswordUpdating ? null : _onChangePasswordPressed,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMD + 2),
                                            minimumSize: const Size(double.infinity, 50),
                                            elevation: 4,
                                          ),
                                          child: isPasswordUpdating
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  'CHANGE PASSWORD',
                                                  style: GoogleFonts.nunito(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: AppConstants.spaceXL),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController confirmController = TextEditingController();
    bool isDeleteEnabled = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spaceLG),
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warning Icon Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      Text(
                        'Delete Account?',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSM),
                      Text(
                        'This action is irreversible. All your data, order history, and saved addresses will be permanently deleted.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLG),
                      GestureDetector(
                        onTap: () {
                          confirmController.text = 'DELETE';
                          setState(() {
                            isDeleteEnabled = true;
                          });
                        },
                        child: Text(
                          'Type "DELETE" to confirm:',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dashed,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSM),
                      TextField(
                        controller: confirmController,
                        onChanged: (val) {
                          setState(() {
                            isDeleteEnabled = val == 'DELETE';
                          });
                        },
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.redAccent.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLG),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMD),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isDeleteEnabled
                                ? () {
                                    Navigator.of(context).pop();
                                    context.read<AuthBloc>().add(AuthDeleteAccountRequested(userId: widget.userId));
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              disabledBackgroundColor: Colors.redAccent.withOpacity(0.3),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isDeleteEnabled ? 4 : 0,
                            ),
                            child: Text(
                              'DELETE',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
             ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpdateBanner(BuildContext context) {
    final info = VersionCheckService().cachedVersionInfo;
    if (info == null || !info.updateRequired) {
      return const SizedBox.shrink();
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceSM),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: -2,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: -1,
                )
              ],
      ),
      child: InkWell(
        onTap: () => VersionCheckService().showUpdateDialog(context, forceShow: true),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Left circular icon with a reload/refresh double arrow icon inside
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
                child: const Icon(
                  Icons.cached_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              
              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Available',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enjoy a more seamless shopping experience',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Right: a badge with green background and white text "New" and a right chevron ">"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.successColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'New',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppConstants.accentSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
