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
import '../../../diamond/presentation/pages/diamond_search_page.dart';
import 'edit_profile_page.dart';
import '../widgets/app_drawer.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../wishlist/presentation/bloc/wishlist_cubit.dart';
import '../../../diamond/presentation/bloc/diamond_bloc.dart';
import '../../../diamond/presentation/bloc/diamond_event.dart';
import '../../../diamond/presentation/bloc/diamond_state.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/services/version_check_service.dart';
import 'dart:ui';

class DashboardPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const DashboardPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch events so data is available
    context.read<DiamondBloc>().add(const FetchDiamonds()); // Just to get total count
    if (widget.userId != 'guest') {
      context.read<WishlistCubit>().fetchWishlist();
      context.read<CartBloc>().add(FetchCart());
      context.read<AuthBloc>().add(AuthGetProfileRequested(userId: widget.userId));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppVersion();
    });
  }

  void _checkAppVersion() async {
    final service = VersionCheckService();
    final result = await service.checkVersion();
    if (result != null && result.updateRequired && mounted) {
      service.showUpdateDialog(context);
    }
  }

  String _getGreeting() {
    return 'Hello';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    // Dynamic Counts
    final diamondState = context.watch<DiamondBloc>().state;
    int totalDiamonds = 0;
    if (diamondState is DiamondLoaded) {
      totalDiamonds = diamondState.unfilteredTotalCount;
      if (totalDiamonds == 0) totalDiamonds = diamondState.totalRecords;
    }

    final wishlistState = context.watch<WishlistCubit>().state;
    int wishlistCount = 0;
    if (wishlistState is WishlistLoaded) wishlistCount = wishlistState.items.length;

    final cartState = context.watch<CartBloc>().state;
    int cartCount = 0;
    if (cartState is CartLoaded) cartCount = cartState.cartItems.length;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthProfileLoadFailure) {
          if (state.errorMessage.contains('User not found') || state.errorMessage.contains('not found')) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (context.mounted) {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
      backgroundColor: isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      drawer: AppDrawer(
        currentPage: 'dashboard',
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.15),
                boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.accentSecondary.withValues(alpha: 0.1),
                boxShadow: [BoxShadow(color: AppConstants.accentSecondary.withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),

            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Sleek Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // User Avatar with glowing status ring (Tapping opens the dynamic sidebar Drawer)
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [accentColor, accentColor.withOpacity(0.5)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.userName.substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(width: AppConstants.spaceMD),
                            // Expanded(
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Text(
                            //         '${_getGreeting()},',
                            //         maxLines: 1,
                            //         overflow: TextOverflow.ellipsis,
                            //         style: GoogleFonts.nunito(
                            //           fontSize: 13,
                            //           fontWeight: FontWeight.w600,
                            //           color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                            //         ),
                            //       ),
                            //       Text(
                            //         widget.userName,
                            //         maxLines: 1,
                            //         overflow: TextOverflow.ellipsis,
                            //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            //               fontWeight: FontWeight.w900,
                            //               fontSize: 22,
                            //               letterSpacing: -0.5,
                            //             ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // App Bar Actions (Theme Toggle + Wishlist + Cart + Logout)
                      Row(
                        children: [
                          // Global Theme Switcher
                          IconButton(
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
                              side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Wishlist Badge Button
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.favorite_border_rounded,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (widget.userId == 'guest') {
                                    DialogUtils.showLoginRequiredDialog(context);
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const WishlistPage()),
                                  );
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
                                  side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              if (wishlistCount > 0)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppConstants.accentSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '$wishlistCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),

                          // Cart Badge Button
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (widget.userId == 'guest') {
                                    DialogUtils.showLoginRequiredDialog(context);
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CartPage()),
                                  );
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
                                  side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              if (cartCount > 0)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppConstants.accentSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '$cartCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          
                          // Logout Button
                          IconButton(
                            icon: Icon(
                              widget.userId == 'guest'
                                  ? Icons.login_rounded
                                  : Icons.power_settings_new_rounded,
                              color: widget.userId == 'guest'
                                  ? accentColor
                                  : AppConstants.errorColor,
                              size: 20,
                            ),
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final authBloc = context.read<AuthBloc>();
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              authBloc.add(const AuthLogoutRequested());
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
                              side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppConstants.spaceXL),
                  
                  // 2. High-End KPI Metric Panel (Enterprise Dashboard Style)
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceLG),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                      boxShadow: AppConstants.glassShadow,
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppConstants.surfaceColor, const Color(0xFF13131B)]
                            : [Colors.white, const Color(0xFFF1F1F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              color: accentColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'OPERATIONAL METRICS',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spaceMD),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildKpiStat(context, 'Total Diamonds', '$totalDiamonds', accentColor),
                            _buildKpiDivider(),
                            _buildKpiStat(context, 'Wishlist', '$wishlistCount Items', AppConstants.accentSecondary),
                            _buildKpiDivider(),
                            _buildKpiStat(context, 'Cart Items', '$cartCount', AppConstants.successColor),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spaceXL),

                  // 3. Section: Core Inventory & Commerce
                  _buildSectionHeader('CORE INVENTORY & SEARCH'),
                  const SizedBox(height: AppConstants.spaceMD),
                  
                  _DashboardTile(
                    title: 'Natural Diamond Search',
                    subtitle: 'Browse through $totalDiamonds high-quality GIA & IGI certified stones.',
                    icon: Icons.diamond_outlined,
                    accentColor: accentColor,
                    badgeText: '$totalDiamonds',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiamondSearchPage(
                            currentCartCount: cartCount,
                            onCartUpdated: (newCount) {
                              // Handled globally by CartBloc now
                            },
                            userId: widget.userId,
                            userName: widget.userName,
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spaceMD),
                  
                  _DashboardTile(
                    title: 'My Saved Wishlist',
                    subtitle: 'View, compare and manage your selected stones.',
                    icon: Icons.favorite_border_rounded,
                    accentColor: AppConstants.accentSecondary,
                    badgeText: '$wishlistCount',
                    onTap: () {
                      if (widget.userId == 'guest') {
                        DialogUtils.showLoginRequiredDialog(context);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WishlistPage()),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spaceMD),
                  
                  _DashboardTile(
                    title: 'Checkout & Cart',
                    subtitle: 'Complete active transactions or review past invoice items.',
                    icon: Icons.shopping_cart_outlined,
                    accentColor: const Color(0xFFFFB03A),
                    badgeText: '$cartCount',
                    onTap: () {
                      if (widget.userId == 'guest') {
                        DialogUtils.showLoginRequiredDialog(context);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    },
                  ),

                  const SizedBox(height: AppConstants.spaceXL),

                  // 4. Section: Account Security & Bank
                  _buildSectionHeader('SECURITY & SETTINGS'),
                  const SizedBox(height: AppConstants.spaceMD),

                  _DashboardTile(
                    title: 'Edit Profile Info',
                    subtitle: 'Update your corporate account and contact details.',
                    icon: Icons.badge_outlined,
                    accentColor: const Color(0xFF00D2FF),
                    onTap: () {
                      if (widget.userId == 'guest') {
                        DialogUtils.showLoginRequiredDialog(context);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(
                            userId: widget.userId,
                            initialTab: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spaceMD),

                  _DashboardTile(
                    title: 'Change Account Password',
                    subtitle: 'Update your access credentials to keep your session secure.',
                    icon: Icons.lock_outline_rounded,
                    accentColor: const Color(0xFF10B981),
                    onTap: () {
                      if (widget.userId == 'guest') {
                        DialogUtils.showLoginRequiredDialog(context);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(
                            userId: widget.userId,
                            initialTab: 1,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spaceMD),

                  // _DashboardTile(
                  //   title: 'Wire/ACH Bank Details',
                  //   subtitle: 'Access direct deposit numbers and payment transfer guidelines.',
                  //   icon: Icons.account_balance_outlined,
                  //   accentColor: const Color(0xFFC780FF),
                  //   onTap: () => _showActionSnackbar(context, 'Wire/ACH Info'),
                  // ),
                  
                  // const SizedBox(height: AppConstants.spaceXL),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiStat(BuildContext context, String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 32,
      width: 1,
      color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSM),
    );
  }

  void _showActionSnackbar(BuildContext context, String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accessing $actionName panel...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

}


class _DashboardTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String? badgeText;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.badgeText,
    required this.onTap,
  });

  @override
  State<_DashboardTile> createState() => _DashboardTileState();
}

class _DashboardTileState extends State<_DashboardTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: _isPressed 
                ? widget.accentColor.withOpacity(0.8) 
                : (isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
            width: _isPressed ? 1.5 : 1.0,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.1),
                    blurRadius: 16.0,
                    spreadRadius: 1.0,
                  )
                ]
              : AppConstants.glassShadow,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLG,
          vertical: AppConstants.spaceMD + 2,
        ),
        child: Row(
          children: [
            // Left Icon wrapper with soft color ring
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceMD - 2),
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: widget.accentColor.withOpacity(0.15)),
              ),
              child: Icon(
                widget.icon,
                color: widget.accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppConstants.spaceLG),
            
            // Middle text info details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Right optional badge or Chevron
            const SizedBox(width: AppConstants.spaceMD),
            if (widget.badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.badgeText != '0' 
                      ? widget.accentColor.withOpacity(0.15) 
                      : (isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: widget.badgeText != '0' 
                        ? widget.accentColor.withOpacity(0.3) 
                        : (isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                  ),
                ),
                child: Text(
                  widget.badgeText!,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: widget.badgeText != '0' ? widget.accentColor : (isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}
