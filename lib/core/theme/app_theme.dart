import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    
    return baseTheme.copyWith(
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.accentColorDark,
        surface: AppConstants.surfaceColor,
        error: AppConstants.errorColor,
        onPrimary: AppConstants.textPrimary,
        onSecondary: Colors.white,
        onSurface: AppConstants.textPrimary,
        onError: Colors.white,
      ),

      // Text Theme with Nunito font family
      textTheme: GoogleFonts.nunitoTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppConstants.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppConstants.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppConstants.textSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Input Decoration Theme for TextFields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceLightColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLG,
          vertical: AppConstants.spaceMD + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.borderAccentDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.errorColor, width: 1.5),
        ),
        labelStyle: GoogleFonts.nunito(
          color: AppConstants.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.nunito(
          color: AppConstants.textMuted,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: AppConstants.borderLight, width: 1),
        ),
        elevation: 0,
      ),

      // Text Selection Theme
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppConstants.accentColorDark,
        selectionColor: Color(0x408B5CFF),
        selectionHandleColor: AppConstants.accentColorDark,
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    
    return baseTheme.copyWith(
      primaryColor: const Color(0xFF0F3F70),
      scaffoldBackgroundColor: AppConstants.lightBackgroundColor,
      
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0F3F70),
        secondary: Color(0xFF0F3F70),
        surface: AppConstants.lightSurfaceColor,
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConstants.lightTextPrimary,
        onError: Colors.white,
      ),

      // Text Theme with Nunito font family
      textTheme: GoogleFonts.nunitoTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppConstants.lightTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppConstants.lightTextPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppConstants.lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppConstants.lightTextSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Input Decoration Theme for TextFields (aligned with signup page premium inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceLG,
          vertical: AppConstants.spaceMD + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.lightBorderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.lightBorderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(
            color: Color(0xFF0F3F70),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppConstants.errorColor, width: 1.5),
        ),
        labelStyle: GoogleFonts.nunito(
          color: AppConstants.lightTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.nunito(
          color: AppConstants.lightTextMuted,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppConstants.lightSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppConstants.lightBorderLight, width: 1),
        ),
        elevation: 0,
      ),

      // Text Selection Theme
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF0F3F70),
        selectionColor: Color(0x400F3F70),
        selectionHandleColor: Color(0xFF0F3F70),
      ),
    );
  }
}
