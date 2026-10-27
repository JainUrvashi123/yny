import 'dart:ui';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../diamond/presentation/pages/diamond_search_page.dart';
import '../pages/contact_us_page.dart';
import '../pages/edit_profile_page.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';

import '../../../../core/utils/dialog_utils.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage; // 'dashboard', 'search', 'profile_info', 'change_password', 'contact_us'
  final String userId;
  final String userName;
  final String userEmail;

  const AppDrawer({
    super.key,
    required this.currentPage,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  void _navigateTo(BuildContext context, String page) {
    Navigator.of(context).pop(); // Close drawer first

    if (userId == 'guest' &&
        (page == 'wishlist' ||
            page == 'cart' ||
            page == 'profile_info' ||
            page == 'change_password')) {
      DialogUtils.showLoginRequiredDialog(context);
      return;
    }

    if (currentPage == page) return; // Already on this page

    switch (page) {
      case 'dashboard':
        // Pop back to Dashboard which is the base of the navigation stack
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 'search':
        // Navigate to Diamond Search
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiamondSearchPage(
              currentCartCount: 0,
              onCartUpdated: (_) {},
              userId: userId,
              userName: userName,
              userEmail: userEmail,
            ),
          ),
        );
        break;
      case 'wishlist':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const WishlistPage(),
          ),
        );
        break;
      case 'cart':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CartPage(),
          ),
        );
        break;
      case 'profile_info':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditProfilePage(
              userId: userId,
              initialTab: 0,
            ),
          ),
        );
        break;
      case 'change_password':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditProfilePage(
              userId: userId,
              initialTab: 1,
            ),
          ),
        );
        break;
      case 'contact_us':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ContactUsPage(
              userId: userId,
              userName: userName,
              userEmail: userEmail,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // Frosted Glassmorphism Background blur
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: isDark 
                    ? Colors.black.withOpacity(0.7) 
                    : Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          
          // Outer Lavender Border Glow
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: accentColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Drawer Header (User info block)
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Glow Ring around Avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [accentColor, AppConstants.accentSecondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: isDark ? AppConstants.surfaceColor : Colors.white,
                          child: Text(
                            userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppConstants.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      Text(
                        userName,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (userId != 'guest')
                        Text(
                          userEmail,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.transparent, height: 1),

                // 2. Main Navigation List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSM),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard_rounded,
                        title: 'Home Dashboard',
                        isActive: currentPage == 'dashboard',
                        onTap: () => _navigateTo(context, 'dashboard'),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.diamond_outlined,
                        activeIcon: Icons.diamond_rounded,
                        title: 'Diamond Search',
                        isActive: currentPage == 'search',
                        onTap: () => _navigateTo(context, 'search'),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.favorite_border_rounded,
                        activeIcon: Icons.favorite_rounded,
                        title: 'My Wishlist',
                        isActive: currentPage == 'wishlist',
                        onTap: () => _navigateTo(context, 'wishlist'),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.shopping_cart_outlined,
                        activeIcon: Icons.shopping_cart_rounded,
                        title: 'Shopping Cart',
                        isActive: currentPage == 'cart',
                        onTap: () => _navigateTo(context, 'cart'),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.badge_outlined,
                        activeIcon: Icons.badge_rounded,
                        title: 'Edit Profile Info',
                        isActive: currentPage == 'profile_info',
                        onTap: () => _navigateTo(context, 'profile_info'),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.lock_outline_rounded,
                        activeIcon: Icons.lock_rounded,
                        title: 'Change Password',
                        isActive: currentPage == 'change_password',
                        onTap: () => _navigateTo(context, 'change_password'),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.map_outlined,
                        activeIcon: Icons.map_rounded,
                        title: 'Contact Us',
                        isActive: currentPage == 'contact_us',
                        onTap: () => _navigateTo(context, 'contact_us'),
                      ),
                      _buildDrawerItem(
                        context: context,
                        icon: Icons.star_outline_rounded,
                        activeIcon: Icons.star_rounded,
                        title: 'Rate Our App',
                        isActive: false,
                        onTap: () async {
                          final url = Platform.isIOS
                              ? AppConstants.appStoreUrl
                              : AppConstants.playStoreUrl;
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // 3. Footer Tools (Theme Switch & Logout)
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceLG),
                  child: Column(
                    children: [
                      // Glassmorphic Quick Controls Container
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.black.withOpacity(0.3) 
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                isDark ? 'Dark Theme' : 'Light Theme',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: isDark ? Colors.yellow : AppConstants.lightTextPrimary,
                                size: 20,
                              ),
                              onPressed: () {
                                context.read<ThemeBloc>().add(const ThemeToggleRequested());
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: isDark 
                                    ? AppConstants.surfaceLightColor 
                                    : AppConstants.lightSurfaceLightColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceMD),

                      // Logout button
                      ElevatedButton.icon(
                        icon: Icon(
                          userId == 'guest'
                              ? Icons.login_rounded
                              : Icons.power_settings_new_rounded,
                          size: 18,
                        ),
                        label: Text(
                          userId == 'guest' ? 'LOG IN' : 'LOG OUT',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: userId == 'guest'
                              ? accentColor.withOpacity(0.1)
                              : AppConstants.errorColor.withOpacity(0.1),
                          foregroundColor: userId == 'guest'
                              ? accentColor
                              : AppConstants.errorColor,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: userId == 'guest'
                                  ? accentColor
                                  : AppConstants.errorColor,
                              width: 1.0,
                            ),
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
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppConstants.spaceXS + 2),
      decoration: BoxDecoration(
        color: isActive 
            ? accentColor.withOpacity(0.12) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isActive 
              ? accentColor.withOpacity(0.25) 
              : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive 
              ? accentColor 
              : (isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive 
                ? (isDark ? Colors.white : AppConstants.lightTextPrimary)
                : (isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        onTap: onTap,
      ),
    );
  }
}
