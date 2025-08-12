
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Color Palette - Inspired by contemporary music apps
  static const Color primaryColor = Color(0xFF6366F1); // Modern indigo
  static const Color primaryAccent = Color(0xFF8B5CF6); // Purple accent
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color accentColor = Color(0xFF10B981); // Emerald
  static const Color successColor = Color(0xFF22C55E);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  
  // Modern Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF06B6D4),
    Color(0xFF10B981),
  ];

  // Enhanced Dark Mode Colors
  static const Color darkBackgroundColor = Color(0xFF0A0A0B); // Deeper black
  static const Color darkSurfaceColor = Color(0xFF1C1C1E); // iOS-like dark surface
  static const Color darkCardColor = Color(0xFF2C2C2E); // Elevated surface
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkMutedTextColor = Color(0xFF8E8E93); // iOS secondary text
  static const Color darkBorderColor = Color(0xFF38383A); // Subtle borders

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
  
  // Modern UI Helpers
  static LinearGradient get primaryGradientLinear => const LinearGradient(
    colors: primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get accentGradientLinear => const LinearGradient(
    colors: accentGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get shimmerGradient => const LinearGradient(
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF0F0F0),
      Color(0xFFE0E0E0),
    ],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
  
  static LinearGradient get darkShimmerGradient => const LinearGradient(
    colors: [
      Color(0xFF2A2A2A),
      Color(0xFF3A3A3A),
      Color(0xFF2A2A2A),
    ],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
  
  // Modern Shadow Effects
  static List<BoxShadow> get modernShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 0),
      blurRadius: 2,
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 2),
      blurRadius: 6,
    ),
  ];
  
  // Glass morphism effect
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(0, 8),
        blurRadius: 32,
      ),
    ],
  );
  
  // Neumorphism for light theme
  static BoxDecoration get neumorphismLight => BoxDecoration(
    color: lightSurfaceColor,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        offset: const Offset(-4, -4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(4, 4),
        blurRadius: 8,
      ),
    ],
  );
  
  // Neumorphism for dark theme
  static BoxDecoration get neumorphismDark => BoxDecoration(
    color: darkSurfaceColor,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.05),
        offset: const Offset(-2, -2),
        blurRadius: 6,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(2, 2),
        blurRadius: 6,
      ),
    ],
  );
}
