import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class DialogUtils {
  static void showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? AppConstants.surfaceColor
              : AppConstants.lightSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: BorderSide(
              color: isDark
                  ? AppConstants.borderLight
                  : AppConstants.lightBorderLight,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Login Required',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Text(
            'Please sign in or create an account to access this feature, view pricing, and request diamonds.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? AppConstants.textSecondary
                    : AppConstants.lightTextSecondary,
              ),
              child: Text(
                'CANCEL',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop(); // Close dialog
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppConstants.accentColorDark
                    : AppConstants.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'SIGN IN',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
