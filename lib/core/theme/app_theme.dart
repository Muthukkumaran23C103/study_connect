import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textTertiary,
          ),
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),

      // Card Theme - Fixed
      cardTheme: const CardThemeData(
        elevation: 2,
        color: surfaceColor,
        shadowColor: Colors.black12,
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: textTertiary),
        labelStyle: TextStyle(color: textSecondary),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        background: darkBackground,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: darkTextPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: darkTextPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: darkTextPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: darkTextPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: darkTextPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkTextPrimary,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: darkTextSecondary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: darkTextPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: darkTextPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: darkTextSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkTextPrimary,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: darkTextSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: darkTextSecondary,
          ),
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: darkTextPrimary,
          size: 24,
        ),
      ),

      // Card Theme - Fixed
      cardTheme: const CardThemeData(
        elevation: 4,
        color: darkSurface,
        shadowColor: Colors.black26,
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF334155),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: darkTextSecondary),
        labelStyle: TextStyle(color: darkTextSecondary),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}