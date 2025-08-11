
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF8E44AD);
  static const Color primaryAccent = Color(0xFF9B59B6);
  static const Color secondaryColor = Color(0xFF3498DB);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF39C12);

  // Dark Mode Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkMutedTextColor = Color(0xFF9E9E9E);

  // Light Mode Colors
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFF5F5F5);
  static const Color lightTextColor = Color(0xFF000000);
  static const Color lightMutedTextColor = Color(0xFF616161);

  // Spacing
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;

  // Text Styles
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.manrope(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.bold),
    headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurfaceColor,
        background: lightBackgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextColor,
        onBackground: lightTextColor,
        onError: Colors.white,
      ),
      textTheme: textTheme.apply(
        bodyColor: lightTextColor,
        displayColor: lightTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightTextColor),
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: lightTextColor),
      ),
      cardTheme: CardThemeData(
        color: lightSurfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextColor,
        onBackground: darkTextColor,
        onError: Colors.white,
      ),
      textTheme: textTheme.apply(
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTextColor),
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: darkTextColor),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
    );
  }
}

