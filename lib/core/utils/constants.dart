import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = 'YNY';

  // Design Theme Colors
  static const Color backgroundColor = Color(0xFF0C0C0F);
  static const Color primaryColor = Color(0xFF0C0C0F); 
  
  // Surface and Secondary Colors
  static const Color surfaceColor = Color(0xFF141419);
  static const Color surfaceLightColor = Color(0xFF1C1C24);
  
  // Primary brand accent color
  static const Color accentColor = Color(0xFF013666);
  static const Color accentColorDark = Color(0xFF3B82F6); // Vibrant, readable blue in dark theme
  static const Color accentGlowColor = Color(0x33013666);
  static const Color accentSecondary = Color(0xFFFF5C8A);
  
  // Neutral Text Colors
  static const Color textPrimary = Color(0xFFF3F3F7);
  static const Color textSecondary = Color(0xFF8F8FA3);
  static const Color textMuted = Color(0xFF5F5F73);
  
  // Feedback Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  // Light Theme Colors
  static const Color lightBackgroundColor = Color(0xFFE1E6EB);
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightSurfaceLightColor = Color(0xFFF1F1F5);
  static const Color lightTextPrimary = Color(0xFF0F3F70);
  static const Color lightTextSecondary = Color(0xFF335C85);
  static const Color lightTextMuted = Color(0xFF6E8CA8);
  static const Color lightBorderLight = Color(0xFFCBD5E1);

  // Border Colors
  static const Color borderLight = Color(0xFF353545);
  static const Color borderAccent = Color(0xFF013666);
  static const Color borderAccentDark = Color(0xFF3B82F6);

  // Layout Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Custom Glassmorphism Box Shadow
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: const Color(0xFF013666).withOpacity(0.04),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ];

  // Glowing Text Shadow
  static List<Shadow> textGlow = [
    Shadow(
      color: const Color(0xFF013666).withOpacity(0.6),
      blurRadius: 10,
    ),
  ];

  // Store Links
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.yny.yny';
  static const String appStoreUrl = 'https://apps.apple.com/in/app/yny/id6778314192';
}
